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

        dashboard.config.layout[6] = nil

        alpha.setup(dashboard.config)
    end,
}
