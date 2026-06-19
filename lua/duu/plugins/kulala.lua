return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {},
	keys = {
		{ "<leader>R", "<cmd>lua require('kulala').run()<cr>", desc = "REST: Run Request" },
		{ "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "REST: Toggle Headers/Body" },
		{ "<leader>Rp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "REST: Previous Request" },
		{ "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "REST: Next Request" },
	},
}
