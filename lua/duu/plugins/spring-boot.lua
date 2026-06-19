return {
	"JavaHello/spring-boot.nvim",
	ft = { "java", "yaml", "jproperties" },
	dependencies = {
		"mfussenegger/nvim-jdtls",
	},
	config = function()
		require("spring_boot").setup({})
	end,
}
