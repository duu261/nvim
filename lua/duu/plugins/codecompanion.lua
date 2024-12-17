local function generate_slash_commands()
	local commands = {}
	local picker = "telescope" --  MAKE SURE TO SET YOUR ACTUAL PICKER HERE

	for _, command in ipairs({ "buffer", "file", "help", "symbols" }) do
		commands[command] = {
			opts = {
				provider = (function()
					if picker == "telescope" then
						return "telescope"
					elseif picker == "fzf-lua" then
						return "fzf_lua"
					elseif picker == "fzf.vim" then
						return "fzf_vim"
					else
						return "telescope"
					end
				end)(),
				log_level = "DEBUG", -- or "TRACE"
			},
		}
	end
	return commands
end

return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
		},
		opts = {
			strategies = {
				chat = {
					adapter = "copilot",
					roles = {
						llm = "CodeCompanion",
						user = "Duu",
					},
					slash_commands = generate_slash_commands(),
				},
			},
		},
		keys = {
			{
				"<leader>cc",
				"<cmd>CodeCompanionActions<cr>",
				mode = { "n", "v" },
				noremap = true,
				silent = true,
				desc = "CodeCompanion actions",
			},
			{
				"<leader>ct",
				"<cmd>CodeCompanionChat Toggle<cr>",
				mode = { "n", "v" },
				noremap = true,
				silent = true,
				desc = "CodeCompanion chat",
			},
			{
				"<leader>cd",
				"<cmd>CodeCompanionChat Add<cr>",
				mode = "v",
				noremap = true,
				silent = true,
				desc = "CodeCompanion add to chat",
			},
		},
	},
}
