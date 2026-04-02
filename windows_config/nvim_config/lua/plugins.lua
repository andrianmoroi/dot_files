return {

    { "tpope/vim-fugitive" },

    {
        "rebelot/kanagawa.nvim",
        opts = {
            compile = false,  -- enable compiling the colorscheme
            undercurl = true, -- enable undercurls
            commentStyle = { italic = true },
            functionStyle = {},
            keywordStyle = { italic = true },
            statementStyle = { bold = true },
            typeStyle = {},
            transparent = true,    -- do not set background color
            dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
            terminalColors = true, -- define vim.g.terminal_color_{0,17}
            colors = {             -- add/modify theme and palette colors
                palette = {},
                theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
            },
            theme = "wave",    -- Load "wave" theme
            background = {     -- map the value of 'background' option to a theme
                dark = "wave", -- try "dragon" !
                light = "lotus"
            },
            ---@diagnostic disable-next-line
            overrides = function(colors)
                return {
                    Visual = {
                        bg = "#525249"
                    },
                    CurSearch = {
                        bold = true,
                        fg = "#dcd7ba",
                        bg = "#525249",
                    },
                }
            end
        },
    },

    { "nvim-mini/mini.icons", opts = {} },

    {
        "nvim-mini/mini.files",
        version = '*',
        opts = {
            mappings = {
                go_in_plus = "<Enter>",
                close = "<M-e>",
            },
            windows = {
                preview = true,
                width_preview = 70,
            },
        }
    },

    {
        "nvim-mini/mini.pick",
        opts = {
            mappings = {
                choose_marked = "<C-q>",
            },

            window = {
                config = {
                    width = 500,
                    height = 10
                }
            }
        },
    },

    {
        "nvim-mini/mini.surround",
        opts = {
            mappings = {
                add = 'sa',       -- Add surrounding in Normal and Visual modes
                delete = 'sd',    -- Delete surrounding
                highlight = 'sh', -- Highlight surrounding
                replace = 'sr',   -- Replace surrounding
            },
            n_lines = 1000,
            search_method = "cover_or_next"
        }
    },

    {
        "nvim-mini/mini.statusline",
        opts = {
            use_icons = vim.g.have_nerd_font,
            set_vim_settings = true,
            content = {
                active = function()
                    local mini_status_line = require("mini.statusline")
                    local git_module       = require("git")

                    local fileformat_icon  = function()
                        local icons = { unix = ' LF', dos = ' CRLF', mac = ' CR' }
                        return icons[vim.bo.fileformat] or vim.bo.fileformat
                    end

                    local mode, mode_hl    = mini_status_line.section_mode({ trunc_width = 1000000 })
                    mode                   = git_module.is_mode_enabled() and "" or mode

                    local spell            = vim.api.nvim_get_option_value("spell", {}) and " " or ""
                    local git              = ""
                    -- local git              = mini_status_line.section_git({ trunc_width = 40 })
                    local fileStatus       = vim.bo.modified and "*" or ""
                    local fileinfo         = vim.bo.filetype ~= "" and
                        require("mini.icons").get("filetype", vim.bo.filetype)
                    local location         = '%P of %L [%2v:%-2{virtcol("$") - 1}]'
                    local search           = mini_status_line.section_searchcount({ trunc_width = 10 })

                    local size             = vim.fn.getfsize(vim.fn.getreg('%'))
                    local sizeFormat       = ""

                    if size < 0 then
                        sizeFormat = ""
                    elseif size < 1024 then
                        sizeFormat = string.format('%d B', size)
                    elseif size < 1048576 then
                        sizeFormat = string.format('%.2f KiB', size / 1024)
                    else
                        sizeFormat = string.format('%.2f MiB', size / 1048576)
                    end

                    return mini_status_line.combine_groups({
                        { hl = mode_hl,                  strings = { mode } },
                        '%<', -- Mark general truncate point
                        { hl = 'MiniStatuslineFilename', strings = { "%{expand('%:~:.')}", fileStatus } },
                        '%=', -- End left alignment
                        { hl = 'MiniStatuslineDevinfo',  strings = { vim.fn.reg_recording() ~= "" and "Recording: " .. vim.fn.reg_recording() or "" } },
                        { hl = 'MiniStatuslineFileinfo', strings = { spell, git, fileinfo, sizeFormat, fileformat_icon() } },
                        '%<', -- Mark general truncate point
                        { hl = mode_hl, strings = { search, location } },
                    })
                end,
                inactive = function()
                    return "%{expand('%:~:.')}"
                end
            }
        }
    },

    {
        "lewis6991/gitsigns.nvim",
        opts = {
            diff_opts = {
                internal = false,
            },
            update_debounce = 10,
            gh = true,
        }
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'main',
        lazy = false,
        build = ":TSUpdate"
    },

    {
        'nvim-mini/mini.completion',
        version = '*',
        opts = {
            lsp_completion = {
                source_func = 'omnifunc',
                auto_setup = true
            }
        },
    },

    {
        "seblyng/roslyn.nvim",
        ---@module 'roslyn.config'
        ---@type RoslynNvimConfig
        opts = {},
    },

    { "jlcrochet/vim-razor" },
}
