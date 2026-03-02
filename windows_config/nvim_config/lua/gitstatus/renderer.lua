local M = {}

require("gitstatus.types")

local helper = require("gitstatus.helper")

----------------------------------------
--- Render buffer
----------------------------------------

local ns = vim.api.nvim_create_namespace("git_dashboard")

---@class DrawArea
---@field header {startLine: number, endLine: number}|nil

---@type number
local DrawBufferId = nil

---@type DrawArea
local DrawArea = {
    header = nil,
}


---@param repo RepoState
local function render_if_changed(repo, updated_props)
    -- Added                fg=b3f6c0 bg=nil
    -- Removed              fg=ffc0b9 bg=nil
    -- Tag                  fg=7fb4ca bg=nil
    -- Title                fg=7e9cd8 bg=nil


    if not helper.any_props_updated(
            { 'name', 'branch', 'path' },
            updated_props) then
        return
    end

    local headerArea = DrawArea.header
    local startLine = headerArea and headerArea.startLine or 0
    local endLine = headerArea and headerArea.endLine or 0

    if headerArea ~= nil then
        vim.api.nvim_buf_clear_namespace(DrawBufferId, ns, startLine, endLine)
    end

    local content = {
        "    " .. repo.name,
        "    " .. (repo.branch or "...initializing"),
        "    " .. repo.path,
    }


    vim.api.nvim_buf_set_lines(DrawBufferId, startLine, endLine, false, content)

    -- vim.print(DrawBufferId)
    -- vim.api.nvim_buf_set_extmark(DrawBufferId - 1, ns, startLine + 1, 0, { hl_group = "Title", hl_eol = true })
    --
    -- vim.api.nvim_buf_set_extmark(DrawBufferId - 1, ns, 0, 0, {
    --     hl_group = "Error",
    --     hl_eol = true,
    -- })
    --
    -- vim.api.nvim_buf_add_highlight(DrawBufferId, ns, "Tag", startLine, 5, -1)
    -- vim.api.nvim_buf_add_highlight(DrawBufferId, ns, "Title", startLine + 1, 5, -1)
    -- vim.api.nvim_buf_add_highlight(DrawBufferId, ns, "Added", startLine + 2, 5, -1)


    -- 📝 Last 3 commits:
    --   ├─ 9f8a7b1 • Fix bug in authentication
    --   ├─ 3c4d2e9 • Update README and docs
    --   └─ a1b2c3d • Initial project setup

    -- return {
    --     "",
    --     "    " .. name,
    --     "    " .. (branch or ""),
    --     "    " .. path,
    --     "",
    --     "    " .. remotes,
    --     "",
    -- }
end



---@return nil
function M.render_highlights()
    vim.bo[DrawBufferId].modifiable = true

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

    vim.api.nvim_buf_set_lines(DrawBufferId, 0, -1, false, lines)

    for i, name in ipairs(groups) do
        local ok, _ = pcall(vim.api.nvim_get_hl_by_name, name, true)
        if ok then
            pcall(vim.api.nvim_buf_add_highlight, DrawBufferId, nns, name, i - 1, 0, -1)
        end
    end

    vim.bo[DrawBufferId].modifiable = false
end

---@param repo RepoState
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
    vim.cmd("tabnew")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_set_name(buf, "Gitstatus")

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "my_page"

    DrawBufferId = buf
end

function M.get_buffer_id()
    return DrawBufferId
end

return M
