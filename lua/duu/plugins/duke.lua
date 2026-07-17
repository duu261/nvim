return {
	{
		dir = "~/Projects/java-scaffold.nvim", -- local checkout, no fetch
		name = "duke.nvim",
		main = "duke",
		cond = vim.fn.isdirectory(vim.fn.expand("~/Projects/java-scaffold.nvim")) == 1, -- skip cleanly where checkout absent
		cmd = { -- registers stubs at startup, loads on first use
			"DukeNew",
			"DukeMaven",
			"DukeGradle",
			"DukeSpring",
			"DukeModule",
			"DukeAdd",
			"DukeUpgrade",
			"DukeBootUpgrade",
			"DukeOutdated",
			"DukeRemove",
			"DukeClearCache",
			"DukeLog",
			"DukeHealth",
		},
		opts = {},
	},
}
