return {
	{
		"ThePrimeagen/harpoon",
		lazy = false,
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"letieu/harpoon-lualine",
		},
		keys = {
			{
				"<leader>A",
				function()
					require("harpoon"):list():prepend()
				end,
				desc = "Prepend current file to Harpoon list",
			},
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Add current file to Harpoon list",
			},
			{
				"<C-e>",
				function()
					require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
				end,
				desc = "Toggle quick menu for Harpoon list",
			},
			{
				"<leader><M-h>",
				function()
					require("harpoon"):list():replace_at(1)
				end,
				desc = "Replace file at position 1 in Harpoon list",
			},
			{
				"<leader><M-j>",
				function()
					require("harpoon"):list():replace_at(2)
				end,
				desc = "Replace file at position 2 in Harpoon list",
			},
			{
				"<leader><M-k>",
				function()
					require("harpoon"):list():replace_at(3)
				end,
				desc = "Replace file at position 3 in Harpoon list",
			},
			{
				"<leader><M-l>",
				function()
					require("harpoon"):list():replace_at(4)
				end,
				desc = "Replace file at position 4 in Harpoon list",
			},
			{
				"<M-h>",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "Select file at position 1 from Harpoon list",
			},
			{
				"<M-j>",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "Select file at position 2 from Harpoon list",
			},
			{
				"<M-k>",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "Select file at position 3 from Harpoon list",
			},
			{
				"<M-l>",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "Select file at position 4 from Harpoon list",
			},
		}, -- Load only when one of the keys is pressed
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup({})
		end,
	},
}
