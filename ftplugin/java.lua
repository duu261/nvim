if vim.bo.buftype ~= "" then
	return
end
local filename = vim.api.nvim_buf_get_name(0)
if not vim.endswith(filename, ".java") then
	return
end

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

	local java_test_path = mason_registry.get_package("java-test"):get_install_path()
	-- these two jars cause classloader conflicts when loaded as bundles
	local excluded = {
		"com.microsoft.java.test.runner-jar-with-dependencies.jar",
		"jacocoagent.jar",
	}
	for _, jar in ipairs(vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n")) do
		if not vim.tbl_contains(excluded, vim.fn.fnamemodify(jar, ":t")) then
			table.insert(bundles, jar)
		end
	end

	vim.list_extend(bundles, require("spring_boot").java_extensions())
	return bundles
end

local function get_workspace(root_dir)
	local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
	return os.getenv("HOME") .. "/code/workspace/" .. project_name
end

local function java_keymaps(client, bufnr)
	local map = function(mode, lhs, rhs, opts)
		opts = opts or {}
		opts.buffer = bufnr
		vim.keymap.set(mode, lhs, rhs, opts)
	end
	local function compile()
		if vim.bo.modified then
			vim.cmd("w")
		end
		---@diagnostic disable-next-line: param-type-mismatch
		client:request_sync("java/buildWorkspace", false, 5000, bufnr)
	end
	local function with_compile(fn)
		return function()
			compile()
			fn()
		end
	end
	local function test_with_profile(test_fn)
		return function()
			local choices = { 'cpu,alloc=2m,lock=10ms', 'cpu', 'alloc', 'wall' }
			vim.ui.select(choices, { format_item = tostring }, function(choice)
				if not choice then return end
				local async_profiler_so = os.getenv("HOME") .. "/apps/async-profiler/lib/libasyncProfiler.so"
				local vmArgs = string.format("-ea -agentpath:%s=start,event=%s,collapsed,file=/tmp/profile.txt", async_profiler_so, choice)
				test_fn({
					config_overrides = { vmArgs = vmArgs, noDebug = true },
					after_test = function()
						vim.cmd.tabnew()
						vim.fn.jobstart({"flamelens", "/tmp/profile.txt"}, { term = true })
						vim.cmd.startinsert()
					end
				})
			end)
		end
	end

	local jdtls = require("jdtls")
	local test_opts = {
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
	map("v", "<leader>Jv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", { desc = "[J]ava Extract [V]ariable" })
	map("n", "<leader>JC", "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = "[J]ava Extract [C]onstant" })
	map("v", "<leader>JC", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", { desc = "[J]ava Extract [C]onstant" })
	map("n", "<leader>Jt", with_compile(function() jdtls.test_nearest_method(test_opts) end), { desc = "[J]ava [T]est Method" })
	map("v", "<leader>Jt", with_compile(function() jdtls.test_nearest_method(vim.tbl_extend("force", test_opts, { true })) end), { desc = "[J]ava [T]est Method" })
	map("n", "<leader>JT", with_compile(function() jdtls.test_class(test_opts) end), { desc = "[J]ava [T]est Class" })
	map("n", "<leader>Jp", with_compile(test_with_profile(jdtls.test_class)), { desc = "[J]ava Test with [P]rofile" })
	map("n", "<leader>JP", function() require('jdtls.dap').pick_test() end, { desc = "[J]ava [P]ick Test" })
	map("n", "<leader>Ju", "<Cmd>JdtUpdateConfig<CR>", { desc = "[J]ava [U]pdate Config" })
	map("v", "<leader>Jm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", { desc = "[J]ava Extract [M]ethod" })
	map("n", "<leader>JM", "<Cmd>lua require('jdtls').extract_variable_all()<CR>", { desc = "[J]ava Extract Variable (All)" })
	map("v", "<leader>JM", "<Esc><Cmd>lua require('jdtls').extract_variable_all(true)<CR>", { desc = "[J]ava Extract Variable (All)" })
	map("n", "<leader>Jg", "<Cmd>lua require('jdtls.tests').generate()<CR>", { desc = "[J]ava [G]enerate Tests" })
	map("n", "<leader>Js", "<Cmd>lua require('jdtls.tests').goto_subjects()<CR>", { desc = "[J]ava Go to [S]ubject" })
end

local jdtls = require("jdtls")
local launcher, os_config, lombok = get_jdtls()
local root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.xml" })
	or vim.fn.getcwd()
local workspace_dir = get_workspace(root_dir)
local bundles = get_bundles()

local jdk23 = os.getenv("JDK23")
local java_cmd = jdk23 and (jdk23 .. "/bin/java") or "java"

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.workspace = { configuration = true }

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
extendedClientCapabilities.onCompletionItemSelectedCommand = "editor.action.triggerParameterHints"

local cmd = {
	java_cmd,
	"-Xshare:off",
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
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
vim.list_extend(cmd, { "-jar", launcher, "-configuration", os_config, "-data", workspace_dir })

local settings = {
	java = {
		autobuild = { enabled = false },
		maxConcurrentBuilds = 8,
		eclipse = { downloadSource = true },
		maven = { downloadSources = true },
		signatureHelp = { enabled = true, description = { enabled = true } },
		compile = { nullAnalysis = { mode = "automatic" } },
		references = { includeDecompiledSources = true },
		implementationsCodeLens = { enabled = true },
		contentProvider = { preferred = "fernflower" },
		saveActions = { organizeImports = true },
		completion = {
			guessMethodArguments = true, -- insert argument placeholders on method completion, IDE-style
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
			runtimes = {
				{ name = "JavaSE-1.8", path = os.getenv("JDK8") },
				{ name = "JavaSE-17", path = os.getenv("JDK17") },
				{ name = "JavaSE-21", path = os.getenv("JDK21"), default = true },
				{ name = "JavaSE-22", path = os.getenv("JDK22") },
				{ name = "JavaSE-23", path = os.getenv("JDK23") },
			},
			updateBuildConfiguration = "automatic", -- re-sync classpath on pom/gradle edits, no prompt
		},
		test = {
			defaultVMArgs = "-Xshare:off -XX:+EnableDynamicAgentLoading -Djdk.instrument.traceUsage"
		},
		referencesCodeLens = { enabled = true },
		inlayHints = { parameterNames = { enabled = "all" } },
	},
}

local on_attach = function(client, bufnr)
	java_keymaps(client, bufnr)
	require("jdtls.dap").setup_dap({ hotcodereplace = "auto" })
	
	vim.api.nvim_buf_create_user_command(bufnr, "A", function()
		require("jdtls.tests").goto_subjects()
	end, { desc = "Alternate between Test and Subject" })
	
	-- can fail if jdtls is slow to start; if ClassDefNotFoundException occurs, run from main class or restart nvim
	require("jdtls.dap").setup_dap_main_class_configs({
		hotcodereplace = "auto",
		config_overrides = {
			vmArgs = "-Xshare:off",
			stepFilters = {
				skipClasses = { "$JDK", "junit.*" },
				skipSynthetics = true,
			},
		},
	})

	if vim.lsp.codelens.enable then
		pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr })
	else
		pcall(vim.lsp.codelens.refresh)
	end

	if vim.lsp.inlay_hint then
		pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
	end

	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		desc = "Auto-organize imports on save",
		callback = function()
			require("jdtls").organize_imports()
		end,
	})
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
		["language/status"] = function() end
	},
	on_attach = on_attach,
})
