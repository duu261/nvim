return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/lazydev.nvim", ft = "lua", opts = {} },
	},
	config = function()
		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local opts = { buffer = ev.buf, silent = true }

				-- Auto-highlight references under cursor
				if client and client.server_capabilities.documentHighlightProvider then
					local hl_augroup = vim.api.nvim_create_augroup("duu-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = ev.buf,
						group = hl_augroup,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = ev.buf,
						group = hl_augroup,
						callback = vim.lsp.buf.clear_references,
					})
				end

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP incoming calls"
				keymap.set("n", "<leader>ci", "<cmd>Telescope lsp_incoming_calls<CR>", opts)

				opts.desc = "Show LSP outgoing calls"
				keymap.set("n", "<leader>co", "<cmd>Telescope lsp_outgoing_calls<CR>", opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Show diagnostics"
				keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Search Workspace Symbols"
				keymap.set("n", "ws", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opts) -- show documentation for what is under cursor

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>lrs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

				opts.desc = "[L]ist Document [S]ymbols"
				keymap.set("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", opts)

				opts.desc = "[W]orkspace [A]dd Folder"
				keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)

				opts.desc = "[W]orkspace [R]emove Folder"
				keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)

				opts.desc = "[W]orkspace [L]ist Folders"
				keymap.set("n", "<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰌶 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- configure lua server (with special settings)
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})
		vim.lsp.enable("lua_ls")

		-- configure lemminx server
		vim.lsp.config("lemminx", {
			capabilities = capabilities,
		})
		vim.lsp.enable("lemminx")

		-- prevent lspconfig from auto-starting jdtls; ftplugin/java.lua manages it manually
		if vim.lsp.config then
			vim.lsp.config("jdtls", { cmd = { "false" } })
		end

		-- Minimalist diagnostic floats (invisible space border for padding)
		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = { " ", " ", " ", " ", " ", " ", " ", " " },
				source = "always",
				header = "",
				prefix = "",
			},
		})
	end,
}
