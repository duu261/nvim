return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
		ft = { "gitcommit", "diff" }, -- Load only for git-related filetypes
		init = function()
			-- Load gitsigns only when a git project is detected
			vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNewFile" }, {
				group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
				callback = function()
					if vim.fn.isdirectory(vim.fn.expand("%:p:h") .. "/.git") == 1 then
						vim.schedule(function()
							require("lazy").load({ plugins = { "gitsigns.nvim" } })
						end)
						vim.api.nvim_clear_autocmds({ group = "GitSignsLazyLoad", buffer = 0 })
					end
				end,
			})
		end,
	},
}
