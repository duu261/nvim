return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			java = { "checkstyle" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				-- Only run checkstyle if there is actually a checkstyle.xml in the project
				if vim.bo.filetype == "java" then
					local checkstyle_xml = vim.fn.findfile("checkstyle.xml", ".;")
					local google_xml = vim.fn.findfile("google_checks.xml", ".;")
					if checkstyle_xml ~= "" or google_xml ~= "" then
						lint.try_lint()
					end
				else
					lint.try_lint()
				end
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
