return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"folke/todo-comments.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	event = "VimEnter", -- Load Telescope on startup
	config = function()
		local telescope = require("telescope")
		local open_with_trouble = require("trouble.sources.telescope").open

		telescope.setup({
			defaults = {
				borderchars = {
					prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				},
				mappings = {
					i = { ["<c-t>"] = open_with_trouble }, -- Open with Trouble in insert mode
					n = { ["<c-t>"] = open_with_trouble }, -- Open with Trouble in normal mode
				},
			},
		})
	end,
	keys = {
		{ "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		{ "<leader>pr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
		{ "<leader>pg", "<cmd>Telescope git_files<cr>", desc = "Find Git Files" },
		{
			"<leader>pws",
			function()
				local word = vim.fn.expand("<cword>")
				require("telescope.builtin").grep_string({ search = word })
			end,
			desc = "Grep current word",
		},
		{
			"<leader>pWs",
			function()
				local word = vim.fn.expand("<cWORD>")
				require("telescope.builtin").grep_string({ search = word })
			end,
			desc = "Grep current WORD",
		},
		{
			"<leader>ps",
			function()
				require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
			end,
			desc = "Grep user input",
		},
		{ "<leader>vh", "<cmd>Telescope help_tags<cr>", desc = "Search Help Tags" },
		{ "<leader>pt", "<cmd>TodoTelescope<cr>", desc = "Find todos" },
	},
}
