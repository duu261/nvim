return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"mfussenegger/nvim-jdtls",
	},
	config = function()
		-- import mason
		local mason = require("mason")

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
		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"java-debug-adapter",
				"java-test",
				"stylua", -- lua formatter
				-- "isort", -- python formatter
				-- "black", -- python formatter
				-- "pylint", -- python linter
				"eslint_d", -- js linter
				"html",
				"tailwindcss",
				"vtsls",
				"cssls",
				"jsonls",
				"bashls",
				"lua_ls",
				"yamlls",
				"dockerls",
				"google-java-format",
				"jdtls",
				"vscode-spring-boot-tools",
				"lemminx",
			},
		})
	end,
}
