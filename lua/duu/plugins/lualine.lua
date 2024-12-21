return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,

	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				section_separators = "",
				component_separators = "⎮",
				theme = "catppuccin-macchiato",
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"diagnostics",
					"branch",
					"diff",
				},
				lualine_c = {
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
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#f5a97f" },
					},

					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {
					{
						"filename",
						path = 3,
						status = true,
					},
				},
				lualine_c = {},
				lualine_x = { "filetype", "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {
				lualine_a = {
					{
						"buffers",
						mode = 4,
					},
				},
				lualine_c = {},
				lualine_b = { "lsp_progress" },
				lualine_x = {},
				lualine_y = { "grapple" },
				lualine_z = { "tabs" },
			},
			-- winbar = {
			-- 	lualine_a = {},
			-- 	lualine_b = {},
			-- 	lualine_c = {
			-- 		-- {  "filename", path = 3, status = true },
			-- 	},
			-- 	lualine_x = {},
			-- 	lualine_y = {},
			-- 	lualine_z = {},
			-- },
			-- inactive_winbar = {
			-- 	lualine_a = {},
			-- 	lualine_b = {},
			-- 	lualine_c = {
			-- 		{
			-- 			-- "filename",
			-- 			-- path = 3,
			-- 			-- status = true,
			-- 		},
			-- 	},
			-- 	lualine_x = {},
			-- 	lualine_y = {},
			-- 	lualine_z = {},
			-- },
		})
	end,
}
