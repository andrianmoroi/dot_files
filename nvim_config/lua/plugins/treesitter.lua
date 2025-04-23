return {
    { -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs", -- Sets main module to use for opts
        -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "diff",
                "html",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc",
            },
            -- Autoinstall languages that are not installed
            auto_install = true,
            highlight = {
                enable = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                additional_vim_regex_highlighting = { "ruby" },
            },
            indent = { enable = true, disable = { "ruby" } },
        },

        -- There are additional nvim-treesitter modules that you can use to interact
        -- with nvim-treesitter. You should go explore a few and see what interests you:
        --
        --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
        --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
        --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
            require('nvim-treesitter.configs').setup({
                auto_install = true,
                modules = {},
                sync_install = true,
                ensure_installed = {},
                ignore_install = {},
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["ab"] = "@block.outer",
                            ["ib"] = "@block.inner",
                            ["al"] = "@loop.outer",
                            ["il"] = "@loop.inner",
                            ["a/"] = "@comment.outer",
                            ["i/"] = "@comment.outer", -- no inner for comment
                            ["aa"] = "@parameter.outer", -- parameter -> argument
                            ["ia"] = "@parameter.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]f"] = "@function.outer",
                            -- ["gj"] = "@function.outer",
                            -- ["]]"] = "@class.outer",
                            -- ["]b"] = "@block.outer",
                            ["]a"] = "@parameter.inner",
                        },
                        goto_next_end = {
                            ["]F"] = "@function.outer",
                            -- ["gJ"] = "@function.outer",
                            -- ["]["] = "@class.outer",
                            -- ["]B"] = "@block.outer",
                            ["]A"] = "@parameter.inner",
                        },
                        goto_previous_start = {
                            ["[f"] = "@function.outer",
                            -- ["gk"] = "@function.outer",
                            -- ["[["] = "@class.outer",
                            -- ["[b"] = "@block.outer",
                            ["[a"] = "@parameter.inner",
                        },
                        goto_previous_end = {
                            ["[F"] = "@function.outer",
                            -- ["gK"] = "@function.outer",
                            -- ["[]"] = "@class.outer",
                            -- ["[B"] = "@block.outer",
                            ["[A"] = "@parameter.inner",
                        },
                    },
                },
            })
        end
    }
}
