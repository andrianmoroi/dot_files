return {
    "goolord/alpha-nvim",
    dependencies = {
        "echasnovski/mini.icons",
        "nvim-lua/plenary.nvim",
    },

    config = function()
        local dashboard = require("alpha.themes.theta")
        local alpha = require 'alpha'
        dashboard.config.layout[2].val = {}

        local filepath = os.getenv("TODO_PATH")

        if filepath ~= nil then
            local file = io.open(filepath, "r")

            if file then
                local content = {}
                local in_progress = {}
                content = file:read("*a")

                for c in string.gmatch(content, "([^\r\n]+)") do
                    if c and (string.sub(c, 1, #"- [-]") == "- [-]") then
                        table.insert(in_progress, c)
                    end
                end

                table.insert(in_progress, "")

                for c in string.gmatch(content, "([^\r\n]+)") do
                    if c and (string.sub(c, 1, #"- [ ]") == "- [ ]") then
                        table.insert(in_progress, c)
                    end
                end

                dashboard.config.layout[2].val = in_progress

                file:close()
            end
        end

        -- -- TODO: Add a more inteligent way to update the layout.
        -- dashboard.config.layout[2].val = {
        --     [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
        --     [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
        --     [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
        --     [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        --     [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        --     [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        --
        --     [[]],
        --     [[]],
        --     [[]],
        --     [[- Fix Visual mode status bar]],
        --     [[- Add Zen mode support]],
        --     [[- Use custom nvim folder with config files]],
        -- }

        dashboard.config.layout[6] = nil

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
