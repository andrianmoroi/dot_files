return {
    "goolord/alpha-nvim",
    dependencies = {
        "echasnovski/mini.icons",
        "nvim-lua/plenary.nvim",
    },

     config = function ()
         local dashboard = require("alpha.themes.theta")
         local alpha = require'alpha'

        -- TODO: Add a more inteligent way to update the layout.
         dashboard.config.layout[2].val = {
             [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
             [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
             [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
             [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
             [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
             [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],

             [[]],
             [[]],
             [[]],
             [[- Fix Visual mode status bar]],
             [[- Add Zen mode support]],
             [[- Improve buffer management shortcuts]],
             [[- Use custom nvim folder with config files]],
         }


         alpha.setup(dashboard.config)
     end,

    init = function()
        if vim.fn.argc(-1) == 1 then
            local stat = vim.loop.fs_stat(vim.fn.argv(0))
            if stat and stat.type == "directory" then
                require("neo-tree").setup({
                    filesystem = {
                        hijack_netrw_behavior = "open_current",
                    },
                })
            end
        end
    end,
}
