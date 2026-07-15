return {
	dir = "~/Projects/java-scaffold.nvim",
	name = "java-scaffold.nvim",
	cond = vim.fn.isdirectory(vim.fn.expand("~/Projects/java-scaffold.nvim")) == 1,
	cmd = {
		"JavaScaffoldMaven",
		"JavaScaffoldGradle",
		"JavaScaffoldSpring",
		"JavaScaffoldAddDependency",
		"JavaScaffoldLog",
		"JavaScaffoldHealth",
	},
	keys = {
		{ "<leader>mp", "<cmd>JavaScaffoldMaven<cr>", desc = "Maven new project" },
		{ "<leader>mg", "<cmd>JavaScaffoldGradle<cr>", desc = "Gradle new project" },
		{ "<leader>ms", "<cmd>JavaScaffoldSpring<cr>", desc = "Spring new project" },
		{ "<leader>md", "<cmd>JavaScaffoldAddDependency<cr>", desc = "Spring add dependencies" },
	},
	config = function()
		require("java_scaffold").setup({
			group_id = "com.duu",
			maven = { command = "mvnd" },
			handoff = {
				enabled = true,
				command = { "tmux", "neww", "tmux-sessionizer", "{project}" },
				required_executables = { "tmux-sessionizer", "fzf" },
			},
		})
	end,
}
