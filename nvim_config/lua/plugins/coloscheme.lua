return {
    "rebelot/kanagawa.nvim",
    config = function()
        require("kanagawa").setup({
            transparent=true,
        })


        vim.cmd.colorscheme("kanagawa-wave")
    end

    -- "catppuccin/nvim",
    -- name = "catppuccin",
    -- priority = 1000,
    -- config = function()
    -- 	require("catppuccin").setup({
    --
    -- 		transparent_background = true,
    -- 	})
    -- end,
    -- init = function()
    -- 	vim.cmd.colorscheme("catppuccin")
    -- end,
}
