return {
	"brenoprata10/nvim-highlight-colors",
	opts = {},
	config = function()
		require("nvim-highlight-colors").setup({
			---Render style
			---@usage 'background'|'foreground'|'virtual'
			render = "virtual",

			---Set virtual symbol (requires render to be set to 'virtual')
			virtual_symbol = "",

			---Set virtual symbol suffix (defaults to '')
			virtual_symbol_prefix = "",

			---Set virtual symbol suffix (defaults to ' ')
			virtual_symbol_suffix = " ",

			---Set virtual symbol position()
			---@usage 'inline'|'eol'|'eow'
			---inline mimics VS Code style
			---eol stands for `end of column` - Recommended to set `virtual_symbol_suffix = ''` when used.
			---eow stands for `end of word` - Recommended to set `virtual_symbol_prefix = ' ' and virtual_symbol_suffix = ''` when used.
			virtual_symbol_position = "inline",

			---Highlight hex colors, e.g. '#FFFFFF'
			enable_hex = true,

			---Highlight short hex colors e.g. '#fff'
			enable_short_hex = true,

			---Highlight rgb colors, e.g. 'rgb(0, 0, 0)'
			enable_rgb = true,

			---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
			enable_hsl = true,

			---Highlight CSS variables, e.g. 'var(--testing-color)'
			enable_var_usage = true,

			---Highlight named colors, e.g. 'green'
			enable_named_colors = true,

			---Highlight tailwind colors, e.g. 'bg-blue-500'
			enable_tailwind = true,

			---Set custom colors
			---Label must be properly escaped with '%' to adhere to `string.gmatch`
			--- :help string.gmatch
			custom_colors = {
				{ label = "rgb%(244, 219, 214%)", color = "#f4dbd6" },
				{ label = "f4dbd6", color = "#f4dbd6" },
				{ label = "rgb%(240, 198, 198%)", color = "#f0c6c6" },
				{ label = "f0c6c6", color = "#f0c6c6" },
				{ label = "rgb%(245, 189, 230%)", color = "#f5bde6" },
				{ label = "f5bde6", color = "#f5bde6" },
				{ label = "rgb%(198, 160, 246%)", color = "#c6a0f6" },
				{ label = "c6a0f6", color = "#c6a0f6" },
				{ label = "rgb%(237, 135, 150%)", color = "#ed8796" },
				{ label = "ed8796", color = "#ed8796" },
				{ label = "rgb%(238, 153, 160%)", color = "#ee99a0" },
				{ label = "ee99a0", color = "#ee99a0" },
				{ label = "rgb%(245, 169, 127%)", color = "#f5a97f" },
				{ label = "f5a97f", color = "#f5a97f" },
				{ label = "rgb%(238, 212, 159%)", color = "#eed49f" },
				{ label = "eed49f", color = "#eed49f" },
				{ label = "rgb%(166, 218, 149%)", color = "#a6da95" },
				{ label = "a6da95", color = "#a6da95" },
				{ label = "rgb%(139, 213, 202%)", color = "#8bd5ca" },
				{ label = "8bd5ca", color = "#8bd5ca" },
				{ label = "rgb%(145, 215, 227%)", color = "#91d7e3" },
				{ label = "91d7e3", color = "#91d7e3" },
				{ label = "rgb%(125, 196, 228%)", color = "#7dc4e4" },
				{ label = "7dc4e4", color = "#7dc4e4" },
				{ label = "rgb%(138, 173, 244%)", color = "#8aadf4" },
				{ label = "8aadf4", color = "#8aadf4" },
				{ label = "rgb%(183, 189, 248%)", color = "#b7bdf8" },
				{ label = "b7bdf8", color = "#b7bdf8" },
				{ label = "rgb%(202, 211, 245%)", color = "#cad3f5" },
				{ label = "cad3f5", color = "#cad3f5" },
				{ label = "rgb%(184, 192, 224%)", color = "#b8c0e0" },
				{ label = "b8c0e0", color = "#b8c0e0" },
				{ label = "rgb%(165, 173, 203%)", color = "#a5adcb" },
				{ label = "a5adcb", color = "#a5adcb" },
				{ label = "rgb%(147, 154, 183%)", color = "#939ab7" },
				{ label = "939ab7", color = "#939ab7" },
				{ label = "rgb%(128, 135, 162%)", color = "#8087a2" },
				{ label = "8087a2", color = "#8087a2" },
				{ label = "rgb%(110, 115, 141%)", color = "#6e738d" },
				{ label = "6e738d", color = "#6e738d" },
				{ label = "rgb%(91, 96, 120%)", color = "#5b6078" },
				{ label = "5b6078", color = "#5b6078" },
				{ label = "rgb%(73, 77, 100%)", color = "#494d64" },
				{ label = "494d64", color = "#494d64" },
				{ label = "rgb%(54, 58, 79%)", color = "#363a4f" },
				{ label = "363a4f", color = "#363a4f" },
				{ label = "rgb%(36, 39, 58%)", color = "#24273a" },
				{ label = "24273a", color = "#24273a" },
				{ label = "rgb%(30, 32, 48%)", color = "#1e2030" },
				{ label = "1e2030", color = "#1e2030" },
				{ label = "rgb%(24, 25, 38%)", color = "#181926" },
				{ label = "181926", color = "#181926" },
			},

			-- Exclude filetypes or buftypes from highlighting e.g. 'exclude_buftypes = {'text'}'
			exclude_filetypes = {},
			exclude_buftypes = {},
		})
	end,
}
