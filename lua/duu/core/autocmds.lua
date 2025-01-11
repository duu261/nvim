local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("HighlightYank", {})

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

local DuuGroup = augroup("Duu", {})

-- auto remove trailing white space
autocmd({ "BufWritePre" }, {
	group = DuuGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})
-- Setup our JDTLS server any time we open up a java file
vim.cmd([[
    augroup jdtls_lsp
        autocmd!
        autocmd FileType java lua require'duu.core.jdtls'.setup_jdtls()
    augroup end

    augroup copilot_disable
        autocmd!
        autocmd FileType java Copilot disable
    augroup end
]])
-- Filetype association for Hyprland config files
vim.filetype.add({
	pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})
