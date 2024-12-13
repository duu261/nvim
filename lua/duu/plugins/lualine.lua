return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				section_separators = "",
				component_separators = "⎮",
				theme = "catppuccin-macchiato",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { { "diagnostics" }, { "filename", path = 3 } },
				lualine_x = {
					{
						icon = "󰇥",
						"harpoon2",
						indicators = { "h", "t", "n", "s" },
						active_indicators = { "H", "T", "N", "S" },
						_separator = " ",
					},
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
		})
	end,
}
