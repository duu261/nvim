return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"folke/todo-comments.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},

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

		local builtin = require("telescope.builtin")

		-- Key mappings
		vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find Files" })
		vim.keymap.set("n", "<leader>pr", builtin.oldfiles, { desc = "Find Files" })
		vim.keymap.set("n", "<leader>pg", builtin.git_files, { desc = "Find Git Files" })
		vim.keymap.set("n", "<leader>pws", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end, { desc = "Grep current word" })
		vim.keymap.set("n", "<leader>pWs", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end, { desc = "Grep current WORD" })
		vim.keymap.set("n", "<leader>ps", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end, { desc = "Grep user input" })
		vim.keymap.set("n", "<leader>vh", builtin.help_tags, { desc = "Search Help Tags" })
	end,
	vim.keymap.set("n", "<leader>pt", "<cmd>TodoTelescope<cr>", { desc = "Find todos" }),
}
