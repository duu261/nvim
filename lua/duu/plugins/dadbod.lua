return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
	keys = {
		{ "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
		-- connections are saved here after :DBUIAddConnection; keep out of dotfiles repo
		vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function()
				require("cmp").setup.buffer({
					sources = {
						{ name = "vim-dadbod-completion" },
						{ name = "buffer" },
					},
				})
			end,
		})
	end,
}
