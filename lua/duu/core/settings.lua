---@diagnostic disable: missing-fields
local tab_size = 4

vim.opt.guicursor = ""
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer

vim.opt.laststatus = 3

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.tabstop = tab_size
vim.opt.softtabstop = tab_size
vim.opt.shiftwidth = tab_size
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 15
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.smoothscroll = true

vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode

vim.opt.timeoutlen = 300
vim.opt.updatetime = 200

vim.opt.colorcolumn = "80"

vim.opt.isfname:append("@-@")

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", trail = "⣿", nbsp = "±", extends = "❯", precedes = "❮" }
vim.opt.showbreak = "↪ "
vim.opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}
vim.opt.inccommand = "nosplit"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.linebreak = true -- Wrap lines at convenient points
vim.opt.list = true -- Show some invisible characters (tabs...
vim.opt.mouse = "" -- disalbe mouse mode
vim.opt.jumpoptions = "view"
vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
---@diagnostic disable-next-line: param-type-mismatch
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

if vim.fn.has("nvim-0.11") == 1 then
	vim.opt.completeopt = "menu,menuone,noselect,fuzzy"
else
	vim.opt.completeopt = "menu,menuone,noselect"
end

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
