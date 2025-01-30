---@diagnostic disable: undefined-field
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	init = function()
		vim.g.lualine_laststatus = vim.o.laststatus
		if vim.fn.argc(-1) > 0 then
			-- set an empty statusline till lualine loads
			vim.o.statusline = " "
		else
			-- hide the statusline on the starter page
			vim.o.laststatus = 0
		end
	end,
	opts = function()
		local lualine_require = require("lualine_require")
		lualine_require.require = require

		vim.o.laststatus = vim.g.lualine_laststatus

		local opts = {
			options = {
				theme = "auto",
				section_separators = "",
				component_separators = "⎮",
				globalstatus = vim.o.laststatus == 3,
				disabled_filetypes = {
					statusline = { "dashboard", "alpha" },
					winbar = {
						"dap-repl",
						"dapui_console",
						"dapui_watches",
						"dapui_stacks",
						"dapui_breakpoints",
						"dapui_scopes",
						"dashboard",
						"alpha",
					},
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = {
					{ "diagnostics" },
					{ "filename", status = true },
					{
						icon = "󰇥",
						"harpoon2",
						indicators = { "h", "t", "n", "s" },
						active_indicators = { "H", "T", "N", "S" },
						_separator = " ",
					},
				},
				lualine_x = {
					{
						function()
							return require("noice").api.status.command.get()
						end,
						cond = function()
							return package.loaded["noice"] and require("noice").api.status.command.has()
						end,
					},
					{
						function()
							return require("noice").api.status.mode.get()
						end,
						cond = function()
							return package.loaded["noice"] and require("noice").api.status.mode.has()
						end,
					},
					{
						function()
							return "  " .. require("dap").status()
						end,
						cond = function()
							return package.loaded["dap"] and require("dap").status() ~= ""
						end,
					},
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
					},
					{ "diff" },
					{ "encoding" },
					{ "fileformat" },
					{ "filetype", icon_only = true, separator = "" },
				},
				lualine_y = {
					{ "progress" },
				},
				lualine_z = {
					{ "location" },
				},
			},
			inactive_sections = {
				lualine_c = {
					{
						"filename",
						path = 3,
						status = true,
					},
				},
			},
			extensions = { "nvim-dap-ui", "oil", "lazy", "trouble" },
			winbar = {
				lualine_c = {},
			},
		}

		local trouble = require("trouble")
		local symbols = trouble.statusline({
			mode = "symbols",
			groups = {},
			title = false,
			filter = { range = true },
			format = "{kind_icon}{symbol.name:Normal}",
			hl_group = "lualine_c_normal",
		})
		table.insert(opts.winbar.lualine_c, {
			symbols and symbols.get,
			cond = function()
				return vim.b.trouble_lualine ~= false and symbols.has()
			end,
		})

		return opts
	end,
}
