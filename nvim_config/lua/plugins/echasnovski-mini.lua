local status_line_setup = function()
    local statusline = require("mini.statusline")

    statusline.setup({
        use_icons = vim.g.have_nerd_font,
        set_vim_settings = true,
        content = {
            active = function()
                local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 1000000 })
                local fileStatus    = vim.bo.modified and "*" or ""
                local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 1000000 })
                local location      = MiniStatusline.section_location({ trunc_width = 75 })
                local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

                local size          = vim.fn.getfsize(vim.fn.getreg('%'))
                local sizeFormat    = ""

                if size < 0 then
                    sizeFormat = ""
                elseif size < 1024 then
                    sizeFormat = string.format('%d B', size)
                elseif size < 1048576 then
                    sizeFormat = string.format('%.2f KiB', size / 1024)
                else
                    sizeFormat = string.format('%.2f MiB', size / 1048576)
                end

                return MiniStatusline.combine_groups({
                    { hl = mode_hl,                  strings = { mode } },
                    '%<', -- Mark general truncate point
                    { hl = 'MiniStatuslineFilename', strings = { "%{expand('%:~:.')}", fileStatus } },
                    '%=', -- End left alignment
                    { hl = 'MiniStatuslineDevinfo',  strings = { vim.fn.reg_recording() ~= "" and "Recording: " .. vim.fn.reg_recording() or "" } },
                    { hl = 'MiniStatuslineFileinfo', strings = { fileinfo, sizeFormat } },
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
end

local mini_files_setup = function()
    require('mini.files').setup({
        mappings = {
            close       = '<ESC>',
            go_in       = 'l',
            go_in_plus  = '<ENTER>',
            go_out      = 'h',
            go_out_plus = 'H',
            mark_goto   = "'",
            mark_set    = 'm',
            reset       = '<BS>',
            reveal_cwd  = '@',
            show_help   = 'g?',
            synchronize = '=',
            trim_left   = '<',
            trim_right  = '>',
        },
        windows = {
            preview = true,
            width_focus = 30,
            width_nofocus = 30,
            width_preview = 30,
        }
    })
end


return {
    "echasnovski/mini.nvim",
    config = function()
        status_line_setup()

        mini_files_setup()


        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
    end,
}
