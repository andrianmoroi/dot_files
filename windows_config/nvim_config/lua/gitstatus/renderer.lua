local M = {}

local helper = require("gitstatus.helper")
local types = require("gitstatus.types")
-- local line_diff = require("gitstatus.line_diff")


----------------------------------------
--- Render buffer
----------------------------------------

---@class gitstatus.HL
---@field ADD string
---@field REMOVE string
---@field CHANGE string
---@field TITLE string
---@field TAG string
---@field EMPTY string
local HL = {
    TITLE = "Title",
    TAG = "Tag",
    EMPTY = "Whitespace",

    -- ADD = "Added",
    -- REMOVE = "Removed",
    -- CHANGE = "Changed"

    ADD = "@diff.plus",
    REMOVE = "@diff.minus",
    CHANGE = "@diff.delta"

}


---@type number
local DRAW_BUFFER_ID = -1

local DISPLAY_BUFFER_NAME = "Gitstatus_buffer"
local NS = vim.api.nvim_create_namespace("git_dashboard")


---@class gitstatus.Highlight
---@field start_row number
---@field end_row number
---@field start_column number
---@field end_column number
---@field hl_group string

---@type gitstatus.Highlight[]
local HIGHLIHTS = {}


local function clear_all_highligts()
    vim.api.nvim_buf_clear_namespace(DRAW_BUFFER_ID, NS, 0, -1)
    HIGHLIHTS = {}
end

---@param line number
---@param start_column number
---@param length number
---@param hl_group string
local function add_highlight(line, start_column, length, hl_group)
    HIGHLIHTS[#HIGHLIHTS + 1] = {
        start_row = line,
        end_row = line,
        start_column = start_column,
        end_column = start_column + length,
        hl_group = hl_group
    }
end


local function update_all_highlights()
    if DRAW_BUFFER_ID > -1 then
        for _, h in ipairs(HIGHLIHTS) do
            vim.api.nvim_buf_set_extmark(DRAW_BUFFER_ID,
                NS,
                h.start_row,
                h.start_column,
                {
                    end_row = h.end_row,
                    end_col = h.end_column,
                    hl_group = h.hl_group
                })
        end
    end
end

---@param repo gitstatus.RepoState
local function render_if_changed(repo, updated_props)
    if not helper.any_props_updated({ 'name', 'branch', 'path', 'status', 'commits' }, updated_props) then
        return
    end

    ---@type gitstatus.Highlight[]
    clear_all_highligts()

    local content = {
        "",
        "    Repository:            " .. repo.name,
        "    Reference branch:      " .. (repo.branch or "...initializing"),
        "    Repository local path: " .. repo.path,
        "",
    }

    add_highlight(1, 30, #repo.name, HL.TITLE)
    add_highlight(2, 30, #(repo.branch or "...initializing"), HL.TAG)
    add_highlight(3, 30, #repo.path, HL.TITLE)

    content[#content + 1] = "    Git diffs:"
    content[#content + 1] = ""

    if repo.status then
        for _, file_state in ipairs(repo.status) do
            content[#content + 1] = ">>>" .. file_state.path.cwd_relative_path .. " - " .. #file_state.hunks

            for _, hunk in ipairs(file_state.hunks) do
                for _, line in ipairs(hunk.content) do
                    local l = line.line == "" and line.state ~= types.LINE_STATE.UNCHANGED and "" or line.line
                    content[#content + 1] = l

                    if line.state == types.LINE_STATE.REMOVE then
                        add_highlight(#content - 1, 0, #l, HL.REMOVE)
                    elseif line.state == types.LINE_STATE.ADD then
                        add_highlight(#content - 1, 0, #l, HL.ADD)
                    end
                end

                content[#content + 1] = "----"

                add_highlight(#content - 1, 0, #"----", HL.EMPTY)
            end
        end
    end

    vim.api.nvim_buf_set_lines(DRAW_BUFFER_ID, 0, -1, false, content)

    update_all_highlights()
end



---@return nil
function M.render_highlights()
    vim.bo[DRAW_BUFFER_ID].modifiable = true

    local groups = vim.fn.getcompletion("", "highlight")
    local nns = vim.api.nvim_create_namespace("all_hl_groups")

    local lines = {}
    for _, name in ipairs(groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
        if ok then
            local fg = hl.foreground and string.format("%06x", hl.foreground) or "nil"
            local bg = hl.background and string.format("%06x", hl.background) or "nil"
            local line_text = string.format("%-20s fg=%s bg=%s", name, fg, bg)

            table.insert(lines, line_text)
        end
    end

    vim.api.nvim_buf_set_lines(DRAW_BUFFER_ID, 0, -1, false, lines)

    for i, name in ipairs(groups) do
        local ok, _ = pcall(vim.api.nvim_get_hl_by_name, name, true)
        if ok then
            pcall(vim.api.nvim_buf_add_highlight, DRAW_BUFFER_ID, nns, name, i - 1, 0, -1)
        end
    end

    vim.bo[DRAW_BUFFER_ID].modifiable = false
end

---@param repo gitstatus.RepoState
---@param updated_props string[] | nil
---@return nil
function M.render_buffer(repo, updated_props)
    updated_props = updated_props or vim.tbl_keys(repo)

    if repo == nil then
        helper.error("Cannot render a nil repo.")
        return
    end

    render_if_changed(repo, updated_props)

    -- M.render_highlights()
end

function M.initialize_buffer()
    DRAW_BUFFER_ID = vim.fn.bufnr(DISPLAY_BUFFER_NAME, false)

    if DRAW_BUFFER_ID == -1 then
        vim.cmd("tabnew")

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, buf)
        vim.api.nvim_buf_set_name(buf, DISPLAY_BUFFER_NAME)

        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        vim.bo[buf].filetype = "my_page"

        DRAW_BUFFER_ID = buf
    end
end

function M.get_buffer_id()
    return DRAW_BUFFER_ID
end

return M
