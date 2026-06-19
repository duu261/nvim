return {
	"MagicDuck/grug-far.nvim",
	config = function()
		require("grug-far").setup({
			-- options, see Configuration section below
			-- there are no required options atm
			-- engine = 'ripgrep' is default, but 'astgrep' can be specified
		})

		vim.keymap.set("n", "<leader>sr", "<cmd>GrugFar<CR>", { desc = "Search and Replace (Project-Wide)" })
	end,
}
