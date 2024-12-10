--simple or no config plugin
return {


    {
        "nvim-lua/plenary.nvim",
        name = "plenary",
    },
    {
        "theprimeagen/vim-be-good",
        name = "vimBeGood",
        dependencies =
        "nvim-lua/plenary.nvim",
    },

    "eandrju/cellular-automaton.nvim",

    {
        "ThePrimeagen/vim-apm",
        config = function()
            local apm = require("vim-apm")

            apm:setup({})
            vim.keymap.set("n", "<leader>apm", function() apm:toggle_monitor() end)
        end
    },

    {
        "mbbill/undotree",

        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },



}
