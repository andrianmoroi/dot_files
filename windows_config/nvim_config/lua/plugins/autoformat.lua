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

        formatters = {
            prettier = {
                append_args = { "--tab-width", vim.opt.shiftwidth._value },
            },
        },

        formatters_by_ft = {
            lua = function() -- bufnr
                local args = ""
                if vim.opt.expandtab then
                    args = "--indent-type Spaces"
                end

                return { "stylua" .. args }
            end,

            -- Conform will run multiple formatters sequentially
            python = { "autopep8", "black" },

            -- Conform will run the first available formatter
            -- javascript = function()
            -- 	return { "prettier", "$FILENAME", "--tab-width", vim.opt.shiftwidth._value }
            -- end,

            -- css = function()
            --     return { "prettier", "$FILENAME", "--tab-width", vim.opt.shiftwidth }
            -- end,
            html = { "prettier" },
            css = { "prettier" },
            javascript = { "prettier" },
            typescript = { "prettier" },

            -- javascript = { "clang-format" },
            js = { "clang-format" },
            json = { "clang-format" },

            -- markdown = { "doctoc" },
            sql = { "sqlfmt" },

        },
    },
}
