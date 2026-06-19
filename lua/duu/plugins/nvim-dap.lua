vim.api.nvim_create_augroup("DapGroup", { clear = true })

local function navigate(args)
	local buffer = args.buf

	local wid = nil
	local win_ids = vim.api.nvim_list_wins() -- Get all window IDs
	for _, win_id in ipairs(win_ids) do
		local win_bufnr = vim.api.nvim_win_get_buf(win_id)
		if win_bufnr == buffer then
			wid = win_id
		end
	end

	if wid == nil then
		return
	end

	vim.schedule(function()
		if vim.api.nvim_win_is_valid(wid) then
			vim.api.nvim_set_current_win(wid)
		end
	end)
end

local function create_nav_options(name)
	return {
		group = "DapGroup",
		pattern = string.format("*%s*", name),
		callback = navigate,
	}
end

return {
	{
		"mfussenegger/nvim-dap",
		lazy = false,
		config = function()
			local dap = require("dap")

			vim.keymap.set("n", "<F8>", dap.continue, { desc = "Debug: Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				local line = vim.trim(vim.api.nvim_get_current_line())
				local default
				if vim.bo.filetype == "java" then
					local assert_condition = line:match("^assert ([^:]*)")
					if assert_condition then
						default = vim.trim("!" .. assert_condition)
					end
				end
				local condition = vim.fn.input({ prompt = "Breakpoint condition: ", default = default })
				if condition and condition ~= "" then
					dap.set_breakpoint(condition)
				end
			end, { desc = "Debug: Set Conditional Breakpoint" })

			-- Stop the debugger entirely
			vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Debug: Quit/Terminate" })

			vim.api.nvim_create_user_command("DapVisualize", function(opts)
				local varname = opts.args ~= "" and opts.args or vim.fn.expand("<cexpr>")
				local child_names = vim.split(vim.fn.input({ prompt = "Child Properties: " }), " ")
				local property_names = vim.split(vim.fn.input({ prompt = "Properties: " }), " ")
				local session = require("dap").session() or {}
				local scopes = (session.current_frame or {}).scopes
				local variable = nil
				for _, scope in pairs(scopes or {}) do
					variable = scope.variables[varname]
					if variable then
						break
					end
				end
				if not variable then
					return
				end
				local f = assert(io.open("/tmp/dap.gv", "w"), "Must be able to open file")
				coroutine.wrap(function()
					f:write("digraph G {\n  graph [ layout=dot labelloc=t ]\n")
					local function get_children(v)
						if v.variablesReference == 0 then
							return {}
						end
						local err, result = session:request("variables", { variablesReference = v.variablesReference })
						return result and result.variables or {}
					end
					local function resolve_lazy(v)
						if (v.presentationHint or {}).lazy then
							local resolved = get_children(v)[1]
							resolved.name = v.name
							return resolved
						end
						return v
					end
					local function add_children(parent, parent_name)
						local children = get_children(parent)
						parent_name = parent_name or parent.name
						local property_values = {}
						for _, var in pairs(children) do
							if vim.tbl_contains(property_names, var.name) then
								if var.variablesReference > 0 then
									for _, child_var in pairs(get_children(var)) do
										table.insert(property_values, var.name .. ": " .. resolve_lazy(child_var).value)
									end
								else
									table.insert(property_values, var.value)
								end
							end
						end
						for _, var in pairs(children) do
							local name = parent_name .. "." .. var.name
							var = resolve_lazy(var)
							if vim.tbl_contains(child_names, var.name) or tonumber(var.name) then
								if var.value ~= "" then
									f:write(
										string.format(
											'  "%s" [label=<<b>%s</b><br/>%s>]\n',
											name,
											name,
											table.concat(property_values, "<br/>")
										)
									)
								else
									f:write(string.format('  "%s"\n', name))
								end
								f:write(string.format('  "%s" -> "%s"\n', parent_name, name))
								add_children(var, name)
							end
						end
					end
					variable = resolve_lazy(variable)
					f:write(string.format('  "%s"\n', variable.name))
					add_children(variable)
					f:write("}")
					f:close()
					vim.fn.system("dot -Txlib /tmp/dap.gv")
				end)()
			end, { nargs = "?", desc = "Visualize DAP variables with Graphviz" })
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			require("nvim-dap-virtual-text").setup()

			dapui.setup()

			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
			vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "Debug: Eval Expression" })

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			-- Commented these out so the UI doesn't disappear immediately after a fast test finishes!
			-- dap.listeners.before.event_terminated.dapui_config = function()
			-- 	dapui.close()
			-- end
			-- dap.listeners.before.event_exited.dapui_config = function()
			-- 	dapui.close()
			-- end
		end,
	},
}
