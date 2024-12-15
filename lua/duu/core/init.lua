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

-- Define key mappings outside of the autocommand
local lsp_keymaps = {
	{ "n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Go to Definition" },
	{ "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", "Show Hover Info" },
	{ "n", "<leader>vws", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", "Search Workspace Symbols" },
	{ "n", "<leader>vd", "<cmd>lua vim.diagnostic.open_float()<CR>", "Show Diagnostic" },
	{ "n", "<leader>vca", "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
	{ "n", "<leader>vrr", "<cmd>Telescope lsp_references<CR>", "Show References" },
	{ "n", "<leader>vrn", "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename Symbol" },
	{ "i", "<C-h>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Show Signature Help" },
	{ "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", "Go to Previous Diagnostic" },
	{ "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", "Go to Next Diagnostic" },
}

autocmd("LspAttach", {
	group = DuuGroup,
	callback = function(e)
		local opts = { buffer = e.buf }
		-- Set key mappings with descriptions
		for _, map in ipairs(lsp_keymaps) do
			vim.keymap.set(map[1], map[2], map[3], vim.tbl_extend("force", opts, { desc = map[4] }))
		end
	end,
})
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
