return {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function()
                return vim.fn.executable("make") == 1
            end,
        },
        { "nvim-telescope/telescope-ui-select.nvim" },

        {
            "nvim-tree/nvim-web-devicons",
            enabled = vim.g.have_nerd_font
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
        { "nvim-telescope/telescope-file-browser.nvim", },
    },
    config = function()
        -- Two important keymaps to use while in Telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?

        require("telescope").setup({
            pickers = {
                find_files = {
                    hidden = true
                }
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown(),
                },
            },
        })

        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")
        require("telescope").load_extension("file_browser")
    end,
}
