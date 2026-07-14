vim.g.mapleader = " "

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>") -- Exit terminal mode
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
vim.keymap.set("n", "<M-u>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "Sessionizer: nvim window" })
vim.keymap.set("n", "<M-i>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>", { desc = "Sessionizer: claude window" })
vim.keymap.set("n", "<M-o>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>", { desc = "Sessionizer: lazygit window" })
vim.keymap.set("n", "<M-p>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>", { desc = "Sessionizer: htop window" })
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>", { desc = "Clear highlight search" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll half-page down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll half-page up and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Search next occurrence and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Search previous occurrence and center" })

-- quickfix nav: C-j/C-k belong to smart-splits now
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Go to next quickfix item and center" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Go to previous quickfix item and center" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Go to next location list item and center" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Go to previous location list item and center" })

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search and replace word under cursor" }
)

-- -- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- 1. Backspace to Alternate File
vim.keymap.set("n", "<bs>", "<c-^>", { desc = "Alternate between files" })

-- 2. Smart gf
vim.keymap.set("n", "gf", "gfzv", { desc = "Goto file and unfold" })
vim.keymap.set("n", "gF", "gFzv", { desc = "Goto file and unfold" })

-- 3. Bash-style Command Line
vim.keymap.set("c", "<C-a>", "<Home>", { desc = "Go to beginning of command line" })
vim.keymap.set("c", "<C-e>", "<End>", { desc = "Go to end of command line" })

-- 4. Visual Search & Replace (gs)
vim.keymap.set("x", "gs", [["sy:let @/=@s<CR>cgn]], { desc = "Search and replace selected text" })

-- 5. Command Output Redirect (:R)
vim.cmd([[
func! ReadExCommandOutput(newbuf, cmd) abort
  redir => l:message
  silent! execute a:cmd
  redir END
  if a:newbuf | wincmd n | endif
  silent put=l:message
endf
command! -nargs=+ -bang -complete=command R call ReadExCommandOutput(<bang>0, <q-args>)
]])

---@param n number
---@param multiplier integer
---@return number number
---@return string unit
local function bytesize(n, multiplier)
	if n > multiplier ^ 3 then
		n = n / (multiplier ^ 3)
		return n, "G"
	end
	if n > multiplier ^ 2 then
		n = n / (multiplier ^ 2)
		return n, "M"
	end
	if n > multiplier then
		n = n / multiplier
		return n, "K"
	end
	return n, ""
end

local function universal_decoder()
	local cword = vim.fn.expand("<cword>")
	local num = tonumber(cword:match("[^%d]*(%d+)[^%d]*"))
	if num then
		local n1024, unit1024 = bytesize(num, 1024)
		local n1000, unit1000 = bytesize(num, 1000)
		local bytesizestr = num > 1024 and string.format("%.2f %siB   %.2f %sB", n1024, unit1024, n1000, unit1000) or ""
		local timestamp = num > 253402300800 -- unix timestamp in seconds for 9999-12-31
				and num / 1000.0
			or num
		local char = num < 128 and string.format("char=%c", num) or ""
		vim.print(
			string.format(
				"%s %s 0x%02x   o%o   %s   %s",
				cword,
				char,
				num,
				num,
				os.date("%Y-%m-%d %H:%M", timestamp),
				bytesizestr
			)
		)
	else
		vim.cmd.ascii()
	end
end

vim.keymap.set("n", "ga", universal_decoder, { silent = true, desc = "Universal Number Decoder" })
