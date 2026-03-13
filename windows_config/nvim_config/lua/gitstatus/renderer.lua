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
local HL = {
    TITLE = "Title",
    TAG = "Tag",
    ADD = "@diff.plus",
    REMOVE = "@diff.minus",
    CHANGE = "@diff.delta"
}


-- @diff.delta          fg=dca561 bg=nil
-- @diff.minus          fg=c34043 bg=nil
-- @diff.plus           fg=76946a bg=nil
-- vim.api.nvim_set_hl(0, "Gitstatus_Green", { fg = "#FFFFFF", bg = "#5f00ff", bold = true })
-- vim.api.nvim_set_hl(0, "Gitstatus_Ged", { fg = "#FFFFFF", bg = "#5f00ff", bold = true })

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


---@param highlight gitstatus.Highlight
local function set_highlight(highlight)
    if DRAW_BUFFER_ID > -1 then
        vim.api.nvim_buf_set_extmark(DRAW_BUFFER_ID,
            NS,
            highlight.start_row,
            highlight.start_column,
            {
                end_row = highlight.end_row,
                end_col = highlight.end_column,
                hl_group = highlight.hl_group
            })
    end
end

---@param repo gitstatus.RepoState
local function render_if_changed(repo, updated_props)
    if not helper.any_props_updated({ 'name', 'branch', 'path', 'status', 'commits' }, updated_props) then
        return
    end

    ---@type gitstatus.Highlight[]
    local highlights = {}
    vim.api.nvim_buf_clear_namespace(DRAW_BUFFER_ID, NS, 0, -1)

    local content = {
        "",
        "    Repository:            " .. repo.name,
        "    Reference branch:      " .. (repo.branch or "...initializing"),
        "    Repository local path: " .. repo.path,
        "",
    }

    highlights[#highlights+1] ={
        start_column = 30,
        start_row = 1,
        end_column = 30 + #repo.name,
        end_row = 1,
        hl_group = HL.TITLE
    }

    highlights[#highlights+1] ={
        start_column = 30,
        start_row = 2,
        end_column = 30 + #(repo.branch or "...initializing"),
        end_row = 2,
        hl_group = HL.TAG
    }

    highlights[#highlights+1] ={
        start_column = 30,
        start_row = 3,
        end_column = 30 + #repo.path,
        end_row = 3,
        hl_group = HL.TITLE
    }

    content[#content + 1] = "    Git diffs:"
    content[#content + 1] = ""

    -- Example usage
    -- local a = "--- Compute LCS, DP table, and produce edit opcodes"
    -- local b = "+--- Compute LCS, DP table, and produce edit opcodes"
    -- local ops = line_diff.lcs_with_ops(a, b)
    -- content[#content + 1] = a
    -- content[#content + 1] = b
    --
    -- content[#content + 1] = "Ops:"
    --
    -- for _, o in ipairs(ops) do
    --     content[#content + 1] = o.op .. string.format("%q", o.a) .. "→" .. string.format("%q", o.b)
    -- end



    if repo.status then
        for _, file_state in ipairs(repo.status) do
            content[#content + 1] = ">>>" .. file_state.path.cwd_relative_path .. " - " .. #file_state.hunks

            for _, hunk in ipairs(file_state.hunks) do
                for _, line in ipairs(hunk.content) do
                    content[#content + 1] = line.line

                    if line.state == types.LINE_STATE.REMOVE then
                        highlights[#highlights + 1] = {
                            start_row = #content - 1,
                            start_column = 0,
                            end_row = #content,
                            end_column = #line,
                            hl_group = HL.REMOVE,
                            -- hl_group = "@diff.minus",
                        }
                    elseif line.state == types.LINE_STATE.ADD then
                        highlights[#highlights + 1] = {
                            start_row = #content - 1,
                            start_column = 0,
                            end_row = #content,
                            end_column = #line,
                            hl_group = HL.ADD,
                        }
                    end
                end
            end
        end
    end

    vim.api.nvim_buf_set_lines(DRAW_BUFFER_ID, 0, -1, false, content)

    for _, h in ipairs(highlights) do
        set_highlight(h)
    end
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
