return {
	{
		dir = "~/Projects/clide.nvim", -- local checkout, no fetch
		name = "clide.nvim",
		lazy = false, -- commands register at startup, no eager server
		config = function()
			require("clide").setup({
				-- defaults fine for checkpoint; explicit for clarity:
				log_level = "debug",
				follow = "both",
				terminal = {
					provider = "auto", -- inside tmux → picks tmux pane provider
					-- cmd = "claude",
					cmd = "claude",
				},
			})
		end,
	},
}
