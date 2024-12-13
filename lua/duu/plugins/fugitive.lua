return {
	"tpope/vim-fugitive",
	config = function()
		-- Open Git status
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open Git status" })

		local Duu_Fugitive = vim.api.nvim_create_augroup("Duu_Fugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = Duu_Fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local opts = { buffer = bufnr, remap = false }

				-- Push changes to the remote repository
				vim.keymap.set("n", "<leader>p", function()
					vim.cmd.Git("push")
				end, vim.tbl_extend("force", opts, { desc = "Push changes to remote" }))

				-- Pull with rebase
				vim.keymap.set("n", "<leader>P", function()
					vim.cmd.Git({ "pull", "--rebase" })
				end, vim.tbl_extend("force", opts, { desc = "Pull changes with rebase" }))

				-- Push to a specific branch and set upstream
				vim.keymap.set(
					"n",
					"<leader>t",
					":Git push -u origin ",
					vim.tbl_extend("force", opts, { desc = "Push to specific branch and set upstream" })
				)
			end,
		})

		-- Merge conflict resolution mappings
		vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>", { desc = "Get changes from base branch" })
		vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>", { desc = "Get changes from current branch" })
	end,
}
