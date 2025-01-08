return {
	{
		"goolord/alpha-nvim",
		dependencies = {
			"echasnovski/mini.icons",
			"nvim-lua/plenary.nvim",
			{ "BlakeJC94/alpha-nvim-fortune", branch = "main" },
		},
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Custom header
			local custom_header = [[




 ██████████                         █████   █████  ███
░░███░░░░███                       ░░███   ░░███  ░░░
 ░███   ░░███ █████ ████ █████ ████ ░███    ░███  ████  █████████████
 ░███    ░███░░███ ░███ ░░███ ░███  ░███    ░███ ░░███ ░░███░░███░░███
 ░███    ░███ ░███ ░███  ░███ ░███  ░░███   ███   ░███  ░███ ░███ ░███
 ░███    ███  ░███ ░███  ░███ ░███   ░░░█████░    ░███  ░███ ░███ ░███
 ██████████   ░░████████ ░░████████    ░░███      █████ █████░███ █████
░░░░░░░░░░     ░░░░░░░░   ░░░░░░░░      ░░░      ░░░░░ ░░░░░ ░░░ ░░░░░





]]

			dashboard.section.header.val = custom_header
			dashboard.section.header.opts = { position = "center" }

			-- Menu
			dashboard.section.buttons.val = {
				dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button(
					"f",
					"󰈞  > Find file",
					":Telescope find_files cwd=" .. vim.fn.expand("%:p:h") .. "<CR>"
				),
				dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
				dashboard.button("s", "  > Settings", ":e " .. vim.fn.stdpath("config") .. "/lua/duu<CR>"),
				dashboard.button("l", "  > Plugins NVIM", ":Lazy <CR>"),
				dashboard.button("q", "󰅙  > Quit NVIM", ":qa<CR>"),
			}

			dashboard.section.buttons.opts = { position = "center" }
			-- Footer
			dashboard.section.footer.val = require("alpha.fortune")()
			dashboard.section.footer.opts = { position = "center" }

			-- Setup
			alpha.setup(dashboard.opts)
		end,
		event = "VimEnter", -- Change this to VimEnter
	},
}
