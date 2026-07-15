return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		-- Make sure to specify the main branch module just in case!
		main = "nvim-treesitter",
		init = function()
			local parsers = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"json",
				"xml",
				"yaml",
				"gitignore",
				"go",
				-- Restoring your previous parsers
				"java",
				"properties",
				"regex",
				"sql",
				"bash",
				"c",
				"markdown",
				"markdown_inline",
				"templ",
			}

			local group = vim.api.nvim_create_augroup("DuuTreesitter", { clear = true })

			vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
				group = group,
				callback = function()
					if vim.bo.buftype ~= "" then
						return
					end

					pcall(vim.treesitter.start, 0)
				end,
			})

			-- Install parsers in the background so it doesn't block startup
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "VeryLazy",
				once = true,
				callback = function()
					require("nvim-treesitter").install(parsers)
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		lazy = false,
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
				},
			})
			-- main branch dropped the keymaps table; bindings are manual now
			local function select(query)
				return function()
					require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
				end
			end
			vim.keymap.set({ "x", "o" }, "af", select("@function.outer"), { desc = "outer function" })
			vim.keymap.set({ "x", "o" }, "if", select("@function.inner"), { desc = "inner function" })
			vim.keymap.set({ "x", "o" }, "ac", select("@class.outer"), { desc = "outer class" })
			vim.keymap.set({ "x", "o" }, "ic", select("@class.inner"), { desc = "inner class" })
		end,
	},
}
