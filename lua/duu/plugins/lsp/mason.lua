return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"mfussenegger/nvim-jdtls",
		{ "ray-x/lsp_signature.nvim", opts = {} },
	},
	config = function()
		-- import mason
		local mason = require("mason")

		local mason_nvim_dap = require("mason-nvim-dap") -- import mason-nvim-dap

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup()

		---@diagnostic disable-next-line: missing-fields
		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {},
		})
		mason_nvim_dap.setup()
		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"java-debug-adapter",
				"java-test",
				"stylua", -- lua formatter
				-- "isort", -- python formatter
				-- "black", -- python formatter
				-- "pylint", -- python linter
				-- "eslint_d", -- js linter
				-- "tsserver",
				-- "html",
				-- "cssls",
				-- "jsonls",
				-- "bashls",
				"lua_ls",
				-- "yamlls",
				-- "dockerls",
				"google-java-format",
				"jdtls",
			},
		})
	end,
}
