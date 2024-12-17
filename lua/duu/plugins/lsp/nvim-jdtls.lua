return {
	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"mfussenegger/nvim-dap",
			"ray-x/lsp_signature.nvim",
		},
	},
	{
		"ray-x/lsp_signature.nvim",
		config = function()
			require("lsp_signature").setup()
		end,
	},
}
