return {
	dir = "~/Projects/java-scaffold.nvim",
	name = "java-scaffold.nvim",
	cond = vim.fn.isdirectory(vim.fn.expand("~/Projects/java-scaffold.nvim")) == 1,
	lazy = false,
	cmd = {
		"JavaScaffoldMaven",
		"JavaScaffoldGradle",
		"JavaScaffoldSpring",
		"JavaScaffoldAddDependency",
		"JavaScaffoldLog",
	},
	init = function()
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				vim.keymap.set("n", "<leader>mp", "<cmd>JavaScaffoldMaven<cr>", { desc = "Maven new project" })
				vim.keymap.set("n", "<leader>mg", "<cmd>JavaScaffoldGradle<cr>", { desc = "Gradle new project" })
				vim.keymap.set("n", "<leader>ms", "<cmd>JavaScaffoldSpring<cr>", { desc = "Spring new project" })
				vim.keymap.set(
					"n",
					"<leader>md",
					"<cmd>JavaScaffoldAddDependency<cr>",
					{ desc = "Spring add dependencies" }
				)
			end,
		})
	end,
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
