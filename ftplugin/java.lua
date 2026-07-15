if vim.bo.buftype ~= "" then
	return
end
local filename = vim.api.nvim_buf_get_name(0)
if not vim.endswith(filename, ".java") then
	return
end

-- google-java-format wraps at 100, not 80
vim.opt_local.colorcolumn = "100"

-- java-test bundles can version-skew with JDTLS. Maven/neotest remain the
-- default; opt in only when the installed JDTLS and java-test bundles match.
local enable_jdtls_tests = vim.g.java_jdtls_tests == true

-- Native gf trick
vim.opt_local.path:append({ "src/main/java/**", "src/test/java/**", "**/src/main/java/**", "**/src/test/java/**" })
vim.opt_local.include = [[^\s*import]]
vim.opt_local.includeexpr = [[substitute(v:fname,'\.','/','g')]]

-- Auto-copy classname to "c register on enter
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd("BufEnter", {
	buffer = buf,
	callback = function()
		pcall(function()
			vim.fn.setreg("c", require("jdtls.util").resolve_classname())
		end)
	end,
})

local function get_jdtls()
	local jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()
	local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
	local config = jdtls_path .. "/config_linux"
	local lombok = jdtls_path .. "/lombok.jar"
	return launcher, config, lombok
end

local function get_bundles()
	local mason_registry = require("mason-registry")
	local java_debug_path = mason_registry.get_package("java-debug-adapter"):get_install_path()

	local bundles = {
		vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
	}

	if enable_jdtls_tests then
		local ok, java_test = pcall(mason_registry.get_package, "java-test")
		if not ok or not java_test:is_installed() then
			enable_jdtls_tests = false
			vim.notify("JDTLS tests disabled: java-test is not installed", vim.log.levels.WARN)
		else
			local java_test_path = java_test:get_install_path()
			local java_test_bundles = vim.fn.glob(java_test_path .. "/extension/server/*.jar", true, true)
			if #java_test_bundles == 0 then
				enable_jdtls_tests = false
				vim.notify("JDTLS tests disabled: java-test bundles not found", vim.log.levels.WARN)
			end
			-- these two jars cause classloader conflicts when loaded as bundles
			local excluded = {
				"com.microsoft.java.test.runner-jar-with-dependencies.jar",
				"jacocoagent.jar",
			}
			for _, jar in ipairs(java_test_bundles) do
				if not vim.tbl_contains(excluded, vim.fn.fnamemodify(jar, ":t")) then
					table.insert(bundles, jar)
				end
			end
		end
	end

	-- fernflower decompiler; without these jars contentProvider="fernflower" is inert
	local ok, decompiler = pcall(mason_registry.get_package, "vscode-java-decompiler")
	if ok and decompiler:is_installed() then
		local path = decompiler:get_install_path()
		for _, jar in ipairs(vim.split(vim.fn.glob(path .. "/server/*.jar", 1), "\n")) do
			if jar ~= "" then
				table.insert(bundles, jar)
			end
		end
	end

	vim.list_extend(bundles, require("spring_boot").java_extensions())
	return bundles
end

local function get_workspace(root_dir)
	local canonical_root = vim.uv.fs_realpath(root_dir) or vim.fs.normalize(root_dir)
	local project_name = vim.fn.fnamemodify(canonical_root, ":t")
	local project_hash = vim.fn.sha256(canonical_root):sub(1, 12)
	return vim.fs.joinpath(vim.fn.expand("~/code/workspace"), project_name .. "-" .. project_hash)
end

local function java_keymaps(client, bufnr)
	local map = function(mode, lhs, rhs, opts)
		opts = opts or {}
		opts.buffer = bufnr
		vim.keymap.set(mode, lhs, rhs, opts)
	end
	local function with_compile(fn)
		return function()
			if vim.bo[bufnr].modified then
				local saved, save_error = pcall(vim.api.nvim_buf_call, bufnr, function()
					vim.cmd.write()
				end)
				if not saved then
					vim.notify("Java build skipped: " .. tostring(save_error), vim.log.levels.ERROR)
					return
				end
			end
			local requested, request_error = client:request("java/buildWorkspace", false, function(err, result)
				vim.schedule(function()
					if err then
						local message = type(err) == "table" and err.message or tostring(err)
						vim.notify("Java build failed: " .. message, vim.log.levels.ERROR)
						return
					end
					if result ~= 1 then
						local statuses = { [0] = "failed", [2] = "completed with errors", [3] = "cancelled" }
						vim.notify(
							"Java build " .. (statuses[result] or "returned an unknown status"),
							vim.log.levels.ERROR
						)
						return
					end
					local ok, test_error = pcall(fn)
					if not ok then
						vim.notify("Java test failed to start: " .. tostring(test_error), vim.log.levels.ERROR)
					end
				end)
			end, bufnr)
			if not requested then
				vim.notify("Java build request failed: " .. tostring(request_error), vim.log.levels.ERROR)
			end
		end
	end
	local function test_with_profile(test_fn)
		return function()
			-- Resolve from the managed executable so Ansible upgrades the agent and CLI together.
			local asprof = vim.fn.exepath("asprof")
			local asprof_path = asprof ~= "" and (vim.uv.fs_realpath(asprof) or asprof) or nil
			local profiler_home = asprof_path and vim.fs.dirname(vim.fs.dirname(asprof_path)) or nil
			local async_profiler_so = profiler_home and vim.fs.joinpath(profiler_home, "lib", "libasyncProfiler.so")
				or vim.fn.expand("~/apps/async-profiler/lib/libasyncProfiler.so")
			if vim.fn.filereadable(async_profiler_so) ~= 1 then
				vim.notify("Java profiler unavailable: " .. async_profiler_so, vim.log.levels.ERROR)
				return
			end
			if vim.fn.executable("flamelens") ~= 1 then
				vim.notify("Java profiler viewer unavailable: install flamelens", vim.log.levels.ERROR)
				return
			end
			local choices = { "cpu,alloc=2m,lock=10ms", "cpu", "alloc", "wall" }
			vim.ui.select(choices, { format_item = tostring }, function(choice)
				if not choice then
					return
				end
				local profile_path = vim.fn.tempname() .. ".collapsed"
				local vmArgs = string.format(
					"-ea -agentpath:%s=start,event=%s,collapsed,file=%s",
					async_profiler_so,
					choice,
					profile_path
				)
				test_fn({
					bufnr = bufnr,
					config_overrides = { vmArgs = vmArgs, noDebug = true },
					after_test = function()
						vim.cmd.tabnew()
						local job = vim.fn.jobstart({ "flamelens", profile_path }, { term = true })
						if job <= 0 then
							vim.notify("Failed to start flamelens", vim.log.levels.ERROR)
							return
						end
						vim.cmd.startinsert()
					end,
				})
			end)
		end
	end

	local jdtls = require("jdtls")
	local test_opts = {
		bufnr = bufnr,
		config_overrides = {
			vmArgs = "-Xshare:off -XX:+EnableDynamicAgentLoading -ea -XX:+TieredCompilation -XX:TieredStopAtLevel=1",
			stepFilters = {
				skipClasses = { "$JDK", "junit.*" },
				skipSynthetics = true,
			},
		},
	}
	map("n", "<leader>Jo", "<Cmd>lua require('jdtls').organize_imports()<CR>", { desc = "[J]ava [O]rganize Imports" })
	map("n", "<leader>Jv", "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = "[J]ava Extract [V]ariable" })
	map(
		"v",
		"<leader>Jv",
		"<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
		{ desc = "[J]ava Extract [V]ariable" }
	)
	map("n", "<leader>JC", "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = "[J]ava Extract [C]onstant" })
	map(
		"v",
		"<leader>JC",
		"<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
		{ desc = "[J]ava Extract [C]onstant" }
	)
	local function test_method(lnum)
		with_compile(function()
			local opts = vim.deepcopy(test_opts)
			opts.lnum = lnum
			jdtls.test_nearest_method(opts)
		end)()
	end
	if enable_jdtls_tests then
		map("n", "<leader>Jt", function()
			test_method(vim.api.nvim_win_get_cursor(0)[1])
		end, { desc = "[J]ava [T]est Method" })
		map("v", "<leader>Jt", function()
			test_method(vim.fn.line("'<"))
		end, { desc = "[J]ava [T]est Method" })
		map(
			"n",
			"<leader>JT",
			with_compile(function()
				jdtls.test_class(test_opts)
			end),
			{ desc = "[J]ava [T]est Class" }
		)
		map(
			"n",
			"<leader>Jp",
			with_compile(test_with_profile(jdtls.test_class)),
			{ desc = "[J]ava Test with [P]rofile" }
		)
		map("n", "<leader>JP", function()
			require("jdtls.dap").pick_test()
		end, { desc = "[J]ava [P]ick Test" })
	end
	map("n", "<leader>Ju", "<Cmd>JdtUpdateConfig<CR>", { desc = "[J]ava [U]pdate Config" })
	map(
		"v",
		"<leader>Jm",
		"<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
		{ desc = "[J]ava Extract [M]ethod" }
	)
	map(
		"n",
		"<leader>JM",
		"<Cmd>lua require('jdtls').extract_variable_all()<CR>",
		{ desc = "[J]ava Extract Variable (All)" }
	)
	map(
		"v",
		"<leader>JM",
		"<Esc><Cmd>lua require('jdtls').extract_variable_all(true)<CR>",
		{ desc = "[J]ava Extract Variable (All)" }
	)
	map("n", "<leader>Jr", function()
		local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
		local client_root = vim.fs.normalize(client.config.root_dir or vim.fn.getcwd())
		local stop = vim.fs.dirname(client_root)
		local wrapper = vim.fs.find({ "gradlew", "mvnw" }, {
			path = buffer_dir,
			upward = true,
			stop = stop,
		})[1]
		local root = wrapper and vim.fs.dirname(wrapper) or client_root
		local command
		local gradle_build = vim.fs.find({ "build.gradle.kts", "build.gradle" }, {
			path = buffer_dir,
			upward = true,
			stop = stop,
		})[1]
		local is_gradle = (wrapper and vim.fs.basename(wrapper) == "gradlew") or (not wrapper and gradle_build)
		if is_gradle then
			local gradle = wrapper and "./gradlew" or "gradle"
			local ok, build = pcall(vim.fn.readfile, gradle_build)
			local goal = (ok and table.concat(build, "\n"):find("org%.springframework%.boot")) and "bootRun" or "run"
			command = gradle .. " " .. goal
		else
			local mvn = wrapper and "./mvnw" or "mvn"
			local pom_file = vim.fs.find("pom.xml", { path = buffer_dir, upward = true, stop = stop })[1]
			local ok, pom = pcall(vim.fn.readfile, pom_file or "")
			local goal = (ok and table.concat(pom, "\n"):find("spring%-boot")) and "spring-boot:run"
				or "compile exec:java"
			command = mvn .. " " .. goal
		end
		-- shell stays open after the app exits so crash output survives
		vim.fn.jobstart({ "tmux", "neww", "-n", "run", "-c", root, command .. "; exec $SHELL" })
	end, { desc = "[J]ava [R]un app in tmux window" })
	if enable_jdtls_tests then
		map("n", "<leader>Jg", "<Cmd>lua require('jdtls.tests').generate()<CR>", { desc = "[J]ava [G]enerate Tests" })
		map(
			"n",
			"<leader>Js",
			"<Cmd>lua require('jdtls.tests').goto_subjects()<CR>",
			{ desc = "[J]ava Go to [S]ubject" }
		)
	end
end

local jdtls = require("jdtls")
local launcher, os_config, lombok = get_jdtls()
local root_markers = { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" }
local root_dir = jdtls.setup.find_root(root_markers)
local git_root = jdtls.setup.find_root({ ".git" })
if not root_dir and git_root then
	for _, build_file in ipairs({ "pom.xml", "build.gradle", "build.gradle.kts", "build.xml" }) do
		if vim.uv.fs_stat(vim.fs.joinpath(git_root, build_file)) then
			root_dir = git_root
			break
		end
	end
end
root_dir = root_dir
	or jdtls.setup.find_root({ "pom.xml", "build.gradle", "build.gradle.kts", "build.xml" })
	or git_root
	or vim.fn.getcwd()
local workspace_dir = get_workspace(root_dir)
local bundles = get_bundles()

local runtime_ok, runtime_snapshot = pcall(function()
	return require("java_scaffold").java_runtimes()
end)
runtime_snapshot = runtime_ok and runtime_snapshot or { homes = {}, active = nil }
local discovered_homes = runtime_snapshot.homes
local active_java = runtime_snapshot.active
local launcher_home = active_java and discovered_homes[active_java] or nil
if not launcher_home or tonumber(active_java) < 21 then
	local versions = vim.tbl_keys(discovered_homes)
	table.sort(versions, function(left, right)
		return tonumber(left) > tonumber(right)
	end)
	for _, version in ipairs(versions) do
		if tonumber(version) >= 21 then
			launcher_home = discovered_homes[version]
			break
		end
	end
end
local java_cmd = launcher_home and (launcher_home .. "/bin/java") or "java"

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.workspace = vim.tbl_deep_extend("force", capabilities.workspace or {}, {
	configuration = true,
})

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
extendedClientCapabilities.onCompletionItemSelectedCommand = "editor.action.triggerParameterHints"

local cmd = {
	java_cmd,
	"-Xshare:off",
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dosgi.checkConfiguration=true",
	"-Dosgi.sharedConfiguration.area=" .. os_config,
	"-Dosgi.sharedConfiguration.area.readOnly=true",
	"-Dosgi.configuration.cascaded=true",
	"-Dlog.protocol=true",
	"-Dlog.level=ERROR",
	"-XX:+UseTransparentHugePages",
	"-XX:+AlwaysPreTouch",
	"-Xmx1g",
	"--add-modules=ALL-SYSTEM",
	"--add-opens",
	"java.base/java.util=ALL-UNNAMED",
	"--add-opens",
	"java.base/java.lang=ALL-UNNAMED",
}
if vim.fn.filereadable(lombok) == 1 then
	table.insert(cmd, "-javaagent:" .. lombok)
end
vim.list_extend(cmd, { "-jar", launcher, "-data", workspace_dir })

local settings = {
	java = {
		autobuild = { enabled = false },
		maxConcurrentBuilds = 8,
		eclipse = { downloadSource = true },
		maven = { downloadSources = true },
		signatureHelp = { enabled = true, description = { enabled = true } },
		compile = { nullAnalysis = { mode = "automatic" } },
		references = { includeDecompiledSources = true },
		implementationCodeLens = "all",
		contentProvider = { preferred = "fernflower" },
		completion = {
			guessMethodArguments = "insertBestGuessedArguments",
			postfix = { enabled = true }, -- e.g. `expr.var<Tab>`, `expr.if<Tab>` templates
			favoriteStaticMembers = {
				"org.hamcrest.MatcherAssert.assertThat",
				"org.hamcrest.Matchers.*",
				"org.hamcrest.CoreMatchers.*",
				"org.junit.jupiter.api.Assertions.*",
				"java.util.Objects.requireNonNull",
				"java.util.Objects.requireNonNullElse",
				"org.mockito.Mockito.*",
			},
			filteredTypes = {
				"com.sun.*",
				"io.micrometer.shaded.*",
				"java.awt.*",
				"jdk.*",
				"sun.*",
			},
			importOrder = { "java", "jakarta", "javax", "com", "org" },
		},
		sources = {
			organizeImports = { starThreshold = 9999, staticThreshold = 9999 },
		},
		codeGeneration = {
			toString = {
				template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
			},
			hashCodeEquals = { useJava7Objects = true },
			useBlocks = true,
		},
		project = { sourcePaths = { "src" } },
		configuration = {
			runtimes = (function()
				local runtimes = {}
				local versions = vim.tbl_keys(discovered_homes)
				table.sort(versions, function(left, right)
					return tonumber(left) < tonumber(right)
				end)
				for _, version in ipairs(versions) do
					local name = version == "8" and "JavaSE-1.8" or ("JavaSE-" .. version)
					table.insert(runtimes, {
						name = name,
						path = discovered_homes[version],
						default = version == active_java,
					})
				end
				return runtimes
			end)(),
			updateBuildConfiguration = "automatic", -- re-sync classpath on pom/gradle edits, no prompt
		},
		referencesCodeLens = { enabled = true },
		inlayHints = { parameterNames = { enabled = "all" } },
	},
}
if enable_jdtls_tests then
	settings.java.test = {
		defaultVMArgs = "-Xshare:off -XX:+EnableDynamicAgentLoading -Djdk.instrument.traceUsage",
	}
end

local on_attach = function(client, bufnr)
	java_keymaps(client, bufnr)

	if enable_jdtls_tests then
		vim.api.nvim_buf_create_user_command(bufnr, "A", function()
			require("jdtls.tests").goto_subjects()
		end, { desc = "Alternate between Test and Subject" })
	end

	if vim.lsp.codelens.enable then
		pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr })
	else
		pcall(vim.lsp.codelens.refresh)
	end

	if vim.lsp.inlay_hint then
		pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
	end

	-- NOTE: no organize-imports-on-save autocmd: google-java-format (conform,
	-- BufWritePre) already sorts and removes unused imports synchronously; the
	-- async organize_imports() raced it and could dirty the buffer after save.
	-- <leader>Jo still adds missing imports on demand.
end

require("jdtls").start_or_attach({
	cmd = cmd,
	root_dir = root_dir,
	settings = settings,
	capabilities = capabilities,
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = extendedClientCapabilities,
	},
	handlers = {
		["language/status"] = function() end,
	},
	on_attach = on_attach,
}, {
	dap = {
		hotcodereplace = "auto",
		config_overrides = {
			vmArgs = "-Xshare:off",
			stepFilters = {
				skipClasses = { "$JDK", "junit.*" },
				skipSynthetics = true,
			},
		},
	},
})
