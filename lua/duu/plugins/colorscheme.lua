return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "macchiato",
				transparent_background = false, -- disables setting the background color.
				dim_inactive = {
					enabled = true, -- dims the background color of inactive window
					shade = "dark",
					percentage = 0.10, -- percentage of the shade to apply to the inactive window
				},
				default_integrations = true,
				integrations = {
					which_key = true,
					harpoon = true,
					fidget = true,
					lsp_trouble = true,
					mini = {
						enabled = true,
						indentscope_color = "lavender",
					},
					-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
				},
			})

			-- setup must be called before loading
			vim.cmd.colorscheme("catppuccin")
		end,
		lazy = false,
	},
}
