--simple no config plugin
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
    }

}
