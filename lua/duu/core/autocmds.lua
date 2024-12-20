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
