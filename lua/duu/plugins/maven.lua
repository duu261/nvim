return {
	"yonchando/maven.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	cmd = { "MvnCLI", "MvnNewProject", "SpringStarter", "SpringDependencies" },
	keys = {
		{ "<leader>mc", function() require("mvn").mvn_cli() end, desc = "Maven CLI" },
		{ "<leader>mp", function() require("mvn").mvn_create_project() end, desc = "Maven new project" },
		{ "<leader>ms", function() require("mvn").spring_initializr_project() end, desc = "Spring new project" },
		{ "<leader>md", function() require("mvn").spring_dependencies() end, desc = "Spring add dependencies" },
	},
	config = function()
		require("mvn").setup()
	end,
}
