require("duu.core.settings")
require("duu.core.keymaps")
local augroup = vim.api.nvim_create_augroup
local DuuGroup = augroup("Duu", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
	require("plenary.reload").reload_module(name)
end

vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 50,
		})
	end,
})

-- auto remove trailing white space
autocmd({ "BufWritePre" }, {
	group = DuuGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

autocmd("LspAttach", {
	group = DuuGroup,
	callback = function(e)
		local opts = { buffer = e.buf }

		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, vim.tbl_deep_extend("force", opts, { desc = "Go to Definition" }))
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, vim.tbl_deep_extend("force", opts, { desc = "Show Hover Info" }))
		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, vim.tbl_deep_extend("force", opts, { desc = "Search Workspace Symbols" }))
		vim.keymap.set("n", "<leader>vd", function()
			vim.diagnostic.open_float()
		end, vim.tbl_deep_extend("force", opts, { desc = "Show Diagnostic" }))
		vim.keymap.set("n", "<leader>vca", function()
			vim.lsp.buf.code_action()
		end, vim.tbl_deep_extend("force", opts, { desc = "Code Action" }))
		vim.keymap.set("n", "<leader>vrr", function()
			vim.lsp.buf.references()
		end, vim.tbl_deep_extend("force", opts, { desc = "Show References" }))
		vim.keymap.set("n", "<leader>vrn", function()
			vim.lsp.buf.rename()
		end, vim.tbl_deep_extend("force", opts, { desc = "Rename Symbol" }))
		vim.keymap.set("i", "<C-h>", function()
			vim.lsp.buf.signature_help()
		end, vim.tbl_deep_extend("force", opts, { desc = "Show Signature Help" }))
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.goto_next()
		end, vim.tbl_deep_extend("force", opts, { desc = "Go to Next Diagnostic" }))
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.goto_prev()
		end, vim.tbl_deep_extend("force", opts, { desc = "Go to Previous Diagnostic" }))
	end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
