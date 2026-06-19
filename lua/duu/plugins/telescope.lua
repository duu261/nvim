return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"folke/trouble.nvim",
		"folke/todo-comments.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	event = "VimEnter", -- Load Telescope on startup
	config = function()
		local telescope = require("telescope")
		local trouble = require("trouble.sources.telescope")

		telescope.setup({
			defaults = {
				mappings = {
					i = { ["<c-t>"] = trouble.open }, -- Open with Trouble in insert mode
					n = { ["<c-t>"] = trouble.open }, -- Open with Trouble in normal mode
				},
			},
			extensions = {
				fzf = {},
				["ui-select"] = {
					require("telescope.themes").get_dropdown({}),
				},
			},
		})

		-- Load extensions
		telescope.load_extension("fzf")
		telescope.load_extension("ui-select")
		telescope.load_extension("noice")

		-- ... key mappings ...
	end,
	keys = {
		{ "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		{ "<leader>pb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
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
