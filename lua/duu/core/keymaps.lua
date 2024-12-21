vim.g.mapleader = " "

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>") -- Exit terminal mode
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end, { desc = "Source current file " })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
-- Paste without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })
-- Delete without overwriting register
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without overwriting register" })
-- vim.keymap.set({ "n", "v" }, "<leader>c", '"_c', { desc = "Cut without overwriting register" })

-- Moving lines in visualmode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- Keep cursor in place when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Open tmux sessionizer" })
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>", { desc = "Clear highlight search" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll half-page down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll half-page up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Search next occurrence and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Search previous occurrence and center" })

-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format code with LSP" })

vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Go to next quickfix item and center" })
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Go to previous quickfix item and center" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Go to next location list item and center" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Go to previous location list item and center" })

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search and replace word under cursor" }
)
-- buffers
-- vim.api.nvim_set_keymap("n", "tk", ":blast<enter>", {noremap=false})
-- vim.api.nvim_set_keymap("n", "tj", ":bfirst<enter>", {noremap=false})
-- vim.api.nvim_set_keymap("n", "th", ":bprev<enter>", {noremap=false})
-- vim.api.nvim_set_keymap("n", "tl", ":bnext<enter>", {noremap=false})
-- vim.api.nvim_set_keymap("n", "td", ":bdelete<enter>", {noremap=false})
-- -- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
