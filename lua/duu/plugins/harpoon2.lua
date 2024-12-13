return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"letieu/harpoon-lualine",
		},
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup()

			-- Key mappings for Harpoon
			vim.keymap.set("n", "<leader>A", function()
				harpoon:list():prepend()
			end, { desc = "Prepend current file to Harpoon list" })
			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Add current file to Harpoon list" })
			vim.keymap.set("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Toggle quick menu for Harpoon list" })

			-- Key mappings to replace files at specific positions
			vim.keymap.set("n", "<leader><C-h>", function()
				harpoon:list():replace_at(1)
			end, { desc = "Replace file at position 1 in Harpoon list" })
			vim.keymap.set("n", "<leader><C-t>", function()
				harpoon:list():replace_at(2)
			end, { desc = "Replace file at position 2 in Harpoon list" })
			vim.keymap.set("n", "<leader><C-n>", function()
				harpoon:list():replace_at(3)
			end, { desc = "Replace file at position 3 in Harpoon list" })
			vim.keymap.set("n", "<leader><C-s>", function()
				harpoon:list():replace_at(4)
			end, { desc = "Replace file at position 4 in Harpoon list" })

			-- Key mappings to select files from the Harpoon list
			vim.keymap.set("n", "<C-h>", function()
				harpoon:list():select(1)
			end, { desc = "Select file at position 1 from Harpoon list" })
			vim.keymap.set("n", "<C-t>", function()
				harpoon:list():select(2)
			end, { desc = "Select file at position 2 from Harpoon list" })
			vim.keymap.set("n", "<C-n>", function()
				harpoon:list():select(3)
			end, { desc = "Select file at position 3 from Harpoon list" })
			vim.keymap.set("n", "<C-s>", function()
				harpoon:list():select(4)
			end, { desc = "Select file at position 4 from Harpoon list" })
		end,
	},
}
