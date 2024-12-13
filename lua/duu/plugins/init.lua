return {
	"nvim-lua/plenary.nvim", -- lua functions that many plugins use

	-- Undo tree visualization
	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle UndoTree" })
		end,
	},

	{
		"theprimeagen/vim-be-good",
		name = "vimBeGood",
		dependencies = "nvim-lua/plenary.nvim", -- Requires plenary.nvim
	},
	{
		"szw/vim-maximizer",
		keys = {
			{ "<leader>vm", "<cmd>MaximizerToggle<CR>", desc = "Maximize/minimize a split" },
		},
	},
}
