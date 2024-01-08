return {
    {
        -- neovim theme
        "rebelot/kanagawa.nvim",
        config = function()
            vim.cmd.colorscheme("kanagawa")
        end
    },
    {
        -- surrounding plugin
        "tpope/vim-surround"
    },
    {
        -- fast navigation to a file
        -- TODO: need more investigations
        "ggandor/leap.nvim",
        config = function()
            require('leap').create_default_mappings()
        end
    }
}

