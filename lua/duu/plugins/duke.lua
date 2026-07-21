return {
	{
		dir = "~/Projects/java-scaffold.nvim", -- local checkout, no fetch
		name = "duke.nvim",
		cond = vim.fn.isdirectory(vim.fn.expand("~/Projects/java-scaffold.nvim")) == 1, -- skip cleanly where checkout absent
	},
}
