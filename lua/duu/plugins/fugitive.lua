return {
	"tpope/vim-fugitive",
	keys = {
		{
			"<leader>gs",
			function()
				vim.cmd.Git()
			end,
			desc = "Open Git status",
		},
	},
	config = function()
		-- Open Git status
		-- vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open Git status" }) -- Moved to keys

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

		-- Native GBrowse handler (no vim-rhubarb needed)
		vim.g.fugitive_browse_handlers = {
			function(args)
				if args == nil then
					return ""
				end
				local remote = args.remote
				local path = args.path ~= "" and args.path or nil
				local line1 = args.line1
				local line2 = args.line2
				local commit = args.commit
				local url
				if not remote then
					return ""
				end
				remote = remote:gsub("^ssh://", "")
				-- <user>@<host>:<org>/<project>
				-- <user>@<host>:<org>/<project>.git
				local _, host, org, project = remote:match("([^@]+)@([^:/]+)[:/]([^/]+)/([a-z.-]+)")
				project = project:gsub("%.git$", "")
				if host == "github.com" then
					if path then
						url = { "https://github.com/", org, "/", project, "/blob/", commit, "/", path, "?plain=1" }
					else
						url = { "https://github.com/", org, "/", project, "/commit/", commit }
					end
				end
				if url then
					if path and line1 then
						table.insert(url, "#L" .. tostring(line1))
						if line2 then
							table.insert(url, "-L" .. tostring(line2))
						end
					end
					return table.concat(url, "")
				end
				return ""
			end,
		}
	end,
}
