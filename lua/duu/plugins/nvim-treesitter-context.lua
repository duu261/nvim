return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		max_lines = 4, -- cap so deep Java nesting doesn't eat the screen
	},
}
