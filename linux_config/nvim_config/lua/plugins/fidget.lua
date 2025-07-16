return {
    {
        "j-hui/fidget.nvim",
        opts = {
            notification = {
                window = {
                    winblend = 0
                }
            }
        },
        config = function(_, opts)
            local fidget = require("fidget")

            fidget.setup(opts)

            vim.notify = fidget.notify
        end
    }
}
