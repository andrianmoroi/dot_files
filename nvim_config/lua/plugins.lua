require("lazy").setup({
    {
        "rebelot/kanagawa.nvim",
        config = function()
            vim.cmd.colorscheme("kanagawa")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup ({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

                sync_install = false,
                auto_install = true,

                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },

                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<leader>ss",
                        node_incremental = "<leader>si",
                        scope_incremental = "<leader>sc",
                        node_decremental = "<leader>sd",
                    }
                },

                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                        },
                        selection_modes = {
                            ['@parameter.outer'] = 'v', -- charwise
                            ['@function.outer'] = 'V', -- linewise
                            ['@class.outer'] = '<c-v>', -- blockwise
                        },
                        include_surrounding_whitespace = false,
                    },
                },
            })
        end
    },
    {
        -- surrounding plugin
        "tpope/vim-surround"
    },
    {

        "nvim-lua/plenary.nvim"
    },
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        dependencies = { 'nvim-lua/plenary.nvim' }
    }
})


