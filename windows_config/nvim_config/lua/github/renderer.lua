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
    local toggle_message = state.show_details and "hide" or "show"

    vim.api.nvim_buf_set_lines(state.buf_id, -1, -1, false, {
        Padding .. "┌───────────────────────────────────────────────────┐",
        Padding .. "│ ( / ) - previous / next PR                        │",
        Padding .. "│                                                   │",
        Padding .. "│ r - refresh all PRs      d - " .. toggle_message .. " details         │",
        Padding .. "│ o - open PR in web                                │",
        Padding .. "│ e - edit PR body                                  │",
        Padding .. "└───────────────────────────────────────────────────┘",
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
---@param show_details boolean
local function render_pr(buf_id, pr, show_details)
    local pr_id_marker = string.format("#%d", pr.id)
    local start_index = 1
    local end_index = 1

    local icon = pr.reviewDecision == "REVIEW_REQUIRED" and "" or
        pr.reviewDecision == "APPROVED" and "" or
        " "


    vim.api.nvim_buf_set_lines(buf_id, -1, -1, false, {
        pr_id_marker .. Padding .. string.format("- %s %d %s", icon, pr.id, pr.title),
    })

    if show_details then
        vim.api.nvim_buf_set_lines(buf_id, -1, -1, false, {
            pr_id_marker .. Padding .. string.format("  %s [ %s / %s]", pr.author, pr.state, pr.reviewDecision),
            pr_id_marker .. Padding .. string.format("  %s (commits:%d +%d ~%d -%d)",
                pr.baseRefName,
                pr.commits,
                pr.additions,
                pr.changedFiles,
                pr.deletions
            ),
            "",
        })

        start_index = 4
        end_index = 2
    end

    local line_index = vim.api.nvim_buf_line_count(buf_id)

    for line = line_index - start_index, line_index - end_index do
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
        vim.opt_local.concealcursor = "nvic"

        clear_buffer(state)
        render_logo(state)
        add_space_line(state)
        render_menu(state)
        add_space_line(state)

        if state.is_loading then
            render_loading(state)
        else
            for _, obj in ipairs(state.prs) do
                render_pr(state.buf_id, obj, state.show_details)
            end
        end

        vim.bo[buf_id].modifiable = false
        vim.bo[buf_id].modified = false
    end)
end

return M
