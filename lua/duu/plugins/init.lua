return {
	"nvim-lua/plenary.nvim", -- lua functions that many plugins use

	-- Undo tree visualization
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle UndoTree" },
		},
	},

	{
		"theprimeagen/vim-be-good",
		name = "vimBeGood",
		cmd = { "VimBeGood" }, -- Load only when VimBeGood command is used
	},
	{
		"szw/vim-maximizer",
		keys = {
			{ "<leader>vm", "<cmd>MaximizerToggle<CR>", desc = "Maximize/minimize a split" },
		}, -- Load only when the key is pressed
	},
}
