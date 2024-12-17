return {
	{ "nvim-lua/plenary.nvim", branch = "master" },
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {
			indent = {
				char = "▏", -- This is a slightly thinner char than the default one, check :help ibl.config.indent.char
			},
			scope = {
				show_start = false,
				show_end = false,
			},
		},
	},
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
	-- TODO: some web thing
	-- {
	--   "iamcco/markdown-preview.nvim",
	--   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	--   ft = { "markdown" },
	--   build = function() vim.fn["mkdp#util#install"]() end,
	-- },
}
