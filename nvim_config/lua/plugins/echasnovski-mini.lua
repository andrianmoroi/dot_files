return {
    "echasnovski/mini.nvim",
    config = function()
        local statusline = require("mini.statusline")

        statusline.setup({
            use_icons = vim.g.have_nerd_font,
            set_vim_settings = true,
            content = {
                active = function()
                    local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 1000000 })
                    local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 1000000 })
                    local location      = MiniStatusline.section_location({ trunc_width = 75 })
                    local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

                    return MiniStatusline.combine_groups({
                        { hl = mode_hl,                  strings = { mode } },
                        '%<', -- Mark general truncate point
                        { hl = 'MiniStatuslineFilename', strings = { "%{expand('%:~:.')}" } },
                        '%=', -- End left alignment
                        { hl = 'MiniStatuslineDevinfo',  strings = { vim.fn.reg_recording() ~= "" and "Recording: " .. vim.fn.reg_recording() or "" } },
                        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                        '%<', -- Mark general truncate point
                        { hl = mode_hl, strings = { search, location } },
                    })
                end,
                inactive = function()
                    return "%{expand('%:~:.')}"
                end
            }
        })

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
            return "%2l:%-2v"
        end

        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
    end,
}
