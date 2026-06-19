return {
	"folke/zen-mode.nvim",
	keys = {
		{
			"<leader>zz",
			function()
				require("zen-mode").setup({
					window = {
						width = 90,
						options = {},
					},
				})
				require("zen-mode").toggle()
				vim.wo.wrap = false
				vim.wo.number = true
				vim.wo.relativenumber = true
			end,
			desc = "Toggle Zen Mode (Centered)",
		},
		{
			"<leader>zZ",
			function()
				require("zen-mode").setup({
					window = {
						width = 80,
						options = {},
					},
				})
				require("zen-mode").toggle()
				vim.wo.wrap = false
				vim.wo.number = false
				vim.wo.relativenumber = false
				vim.opt.colorcolumn = "0"
			end,
			desc = "Toggle Zen Mode (Clean)",
		},
	},
}
