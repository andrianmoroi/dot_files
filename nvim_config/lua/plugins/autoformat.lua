return { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>cf",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
    opts = {
        notify_on_error = false,
        formatters_by_ft = {
            lua = function() -- bufnr
                local args = ""
                if vim.opt.expandtab then
                    args = "--indent-type Spaces"
                end

                return { "stylua" .. args }
            end,
        },
    },
}
