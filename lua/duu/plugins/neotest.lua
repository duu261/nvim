return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"rcasia/neotest-java",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-java")({
					ignore_wrapper = false, -- use maven/gradle wrapper if it exists
				}),
			},
			status = { virtual_text = true },
			output = { open_on_run = true },
			quickfix = {
				open = function()
					if pcall(require, "trouble") then
						require("trouble").open({ mode = "quickfix" })
					else
						vim.cmd("copen")
					end
				end,
			},
		})

		-- Test execution mappings
		vim.keymap.set("n", "<leader>tt", function()
			require("neotest").run.run()
		end, { desc = "Test Nearest" })

		vim.keymap.set("n", "<leader>tT", function()
			require("neotest").run.run(vim.fn.expand("%"))
		end, { desc = "Test Current File" })

		vim.keymap.set("n", "<leader>td", function()
			require("neotest").run.run({ strategy = "dap" })
		end, { desc = "Test Debug Nearest" })

		-- Test UI mappings
		vim.keymap.set("n", "<leader>ts", function()
			require("neotest").summary.toggle()
		end, { desc = "Test Summary UI" })

		vim.keymap.set("n", "<leader>to", function()
			require("neotest").output.open({ enter = true, auto_close = true })
		end, { desc = "Test Output" })
	end,
}
