return {
    "rebelot/kanagawa.nvim",
    config = function()
        require("kanagawa").setup({
            transparent=true,
        })

        vim.cmd.colorscheme("kanagawa-wave")

        vim.cmd[[highlight Visual guibg=#525249]]
        vim.cmd[[highlight CurSearch cterm=bold gui=bold guifg=#dcd7ba guibg=#525249]]
    end
}
