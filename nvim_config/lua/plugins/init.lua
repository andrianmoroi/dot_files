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
}

