local M = {}

local Padding = "     "
local ns = vim.api.nvim_create_namespace("dashboard")

require("github.types")

---Clear buffer
---@param state State
local function clear_buffer(state)
    vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, false, {})
end

---Add space line
---@param state State
local function add_space_line(state)
    vim.api.nvim_buf_set_lines(state.buf_id, -1, -1, false, { "" })
end

---Render logo
---@param state State
local function render_logo(state)
    vim.api.nvim_buf_set_lines(state.buf_id, -1, -1, false, {
        Padding .. " ███  ███ █████ █   █ █   █ ████",
        Padding .. "█      █    █   █   █ █   █ █   █",
        Padding .. "█  ██  █    █   █████ █   █ ████",
        Padding .. "█   █  █    █   █   █ █   █ █   █",
        Padding .. " ███  ███   █   █   █  ███  ████",
    })
end

---Render menu
---@param state State
local function render_menu(state)
    vim.api.nvim_buf_set_lines(state.buf_id, -1, -1, false, {
        Padding .. "┌───────────────────────────┐",
        Padding .. "│ r - refresh all PRs       │",
        Padding .. "│ o - open PR in web        │",
        Padding .. "│ e - edit PR body          │",
        Padding .. "└───────────────────────────┘",
    })
end

---Render loading spinner
---@param state State
local function render_loading(state)
    local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

    vim.api.nvim_buf_set_lines(state.buf_id, -1, -1, false, {
        Padding,
    })

    local i = 1
    local timer = vim.uv.new_timer()
    local current_line_number = vim.api.nvim_buf_line_count(state.buf_id) - 1

    if timer ~= nil then
        timer:start(0, 100, vim.schedule_wrap(function()
            if state.is_loading then
                vim.bo[state.buf_id].modifiable = true
                vim.api.nvim_buf_set_lines(state.buf_id, current_line_number, current_line_number + 1, false, {
                    Padding .. frames[i] .. " Loading",
                })

                vim.bo[state.buf_id].modifiable = false
                vim.bo[state.buf_id].modified = false

                i = i % #frames + 1
            else
                timer:stop()
                timer:close()
            end
        end))
    end
end

---Render a PR
---@param buf_id number
---@param pr PR
local function render_pr(buf_id, pr)
    local pr_id_marker = string.format("#%d", pr.id)

    vim.api.nvim_buf_set_lines(buf_id, -1, -1, false, {
        pr_id_marker .. Padding .. string.format("- %d %s", pr.id, pr.title),
        pr_id_marker .. Padding .. string.format("  [ %s ]", pr.state),
        pr_id_marker .. Padding .. string.format("  %s", pr.author),
        "",
    })

    local line_index = vim.api.nvim_buf_line_count(buf_id)

    for line = line_index - 4, line_index - 2 do
        vim.api.nvim_buf_set_extmark(buf_id, ns, line, 0, {
            end_col = #pr_id_marker,
            conceal = "",
        })
    end


end

---Render the state inside buffer
---@param state State
function M.render(state)
    vim.schedule(function()
        local buf_id = state.buf_id

        vim.bo[buf_id].modifiable = true
        vim.opt_local.conceallevel = 3
        vim.opt_local.concealcursor = "n"

        clear_buffer(state)
        render_logo(state)
        add_space_line(state)
        render_menu(state)
        add_space_line(state)

        if state.is_loading then
            render_loading(state)
        else
            for _, obj in ipairs(state.prs) do
                render_pr(state.buf_id, obj)
            end
        end

        vim.bo[buf_id].modifiable = false
        vim.bo[buf_id].modified = false
    end)
end

return M
