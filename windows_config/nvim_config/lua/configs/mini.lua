vim.pack.add({
    "https://github.com/nvim-mini/mini.icons",
    "https://github.com/nvim-mini/mini.files",
    "https://github.com/nvim-mini/mini.pick",
    "https://github.com/nvim-mini/mini.surround",
    "https://github.com/nvim-mini/mini.statusline",
    'https://github.com/nvim-mini/mini.completion',
}, { load = true })


-------------------------------------------------------
--- Mini icons
-------------------------------------------------------

require("mini.icons").setup({})

-------------------------------------------------------
--- Mini files
-------------------------------------------------------

local mini_files = require("mini.files")

mini_files.setup({
    mappings = {
        go_in_plus = "<Enter>",
        close = "<M-e>",
    },
    windows = {
        preview = true,
        width_preview = 70,
    },
})

-------------------------------------------------------
--- Mini pick
-------------------------------------------------------

local mini_pick = require("mini.pick")

mini_pick.setup({
    mappings = {
        choose_marked = "<C-q>",
    },

    window = {
        config = {
            width = 500,
            height = 10
        }
    }
})

-------------------------------------------------------
--- Mini surround
-------------------------------------------------------

require("mini.surround").setup({
    n_lines = 1000,
    search_method = "cover_or_next",
})

-------------------------------------------------------
--- Mini status line
-------------------------------------------------------

require("mini.statusline").setup({
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
})


-------------------------------------------------------
--- Mini icons
-------------------------------------------------------

require("mini.completion").setup({
    lsp_completion = {
        source_func = 'omnifunc',
        auto_setup = true
    }
})


---@class Configs.Mini
---@field files unknown
---@field picker unknown

return {
    files = mini_files,
    picker = mini_pick,
}
