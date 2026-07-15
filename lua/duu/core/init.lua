require("duu.core.settings")
require("duu.core.keymaps")
require("duu.core.autocmds")
require("duu.core.commands")

function R(name)
	require("plenary.reload").reload_module(name)
end

vim.cmd.packadd("cfilter")
