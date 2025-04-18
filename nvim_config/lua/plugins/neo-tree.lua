return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },

    opts = {

        filesystem = {
            filtered_items = {
                hide_by_name = {
                    "__init__.py"
                }
            }
        }
    },
}
