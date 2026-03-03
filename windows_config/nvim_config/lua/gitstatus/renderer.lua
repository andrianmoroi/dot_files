local M = {}

require("gitstatus.types")

local helper = require("gitstatus.helper")


----------------------------------------
--- Render buffer
----------------------------------------


---@type number
local DrawBufferId = -1

local DISPLAY_BUFFER_NAME = "Gitstatus"
local NS = vim.api.nvim_create_namespace("git_dashboard")

---@param repo RepoState
local function render_if_changed(repo, updated_props)
    if not helper.any_props_updated({ 'name', 'branch', 'path', 'status', 'commits' }, updated_props) then
        return
    end


    local content = {
        "",
        "    Repository:            " .. repo.name,
        "    Reference branch:      " .. (repo.branch or "...initializing"),
        "    Repository local path: " .. repo.path,
        "",
        "   --------------------",
        -- "   Git status:",
        -- "",
        -- "   --------------------",
        -- "   Last commits:",
        -- "",
        -- "   --------------------",
    }

    content[#content + 1] = "    Git stauts:"

    if repo.status then
        for _, line in ipairs(repo.status) do
            content[#content + 1] = line
        end
    end

    content[#content + 1] = "   --------------------"
    content[#content + 1] = "    Last commits:"

    if repo.commits then
        for _, c in ipairs(repo.commits) do
            content[#content + 1] = c.hash .. " - " .. c.message
        end
    end

    vim.api.nvim_buf_set_lines(DrawBufferId, 0, -1, false, content)

    -- 📝 Last 3 commits:
    --   ├─ 9f8a7b1 • Fix bug in authentication
    --   ├─ 3c4d2e9 • Update README and docs
    --   └─ a1b2c3d • Initial project setup
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
    DrawBufferId = vim.fn.bufnr(DISPLAY_BUFFER_NAME)

    if DrawBufferId == -1 then
        vim.cmd("tabnew")

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, buf)
        vim.api.nvim_buf_set_name(buf, DISPLAY_BUFFER_NAME)

        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        vim.bo[buf].filetype = "my_page"

        DrawBufferId = buf
    end
end

function M.get_buffer_id()
    return DrawBufferId
end

return M
