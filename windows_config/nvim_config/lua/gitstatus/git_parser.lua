local M = {}

local types = require("gitstatus.types")

---@param repo_path string
---@param file_relative_path string
---@return gitstatus.Path
local function get_path(repo_path, file_relative_path)
    local sep = package.config:sub(1, 1)

    repo_path = repo_path:gsub("[/\\]", sep)
    file_relative_path = file_relative_path:gsub("[/\\]", sep)

    local full_path = repo_path .. sep .. file_relative_path
    local current_path = vim.fn.fnamemodify(full_path, ":~:.")

    return {
        full_path = full_path,
        git_path = file_relative_path,
        cwd_relative_path = current_path,
    }
end

---Parse the git status
---@param repo_path string
---@param content string | nil
---@return gitstatus.FileStatus[]
function M.get_parsed_git_status(repo_path, content)
    ---@type gitstatus.FileStatus[]
    local result = {}

    if content ~= nil then
        local lines = vim.split(content, '\n')

        local temp = vim.tbl_map(function(line)
            if line ~= "" then
                local status, file_path = line:match("^(..)%s(.+)$")
                local path = get_path(repo_path, file_path)

                ---@type gitstatus.FileStatus
                return {
                    path = path,
                    status = status,
                    diffs = {},
                    hunks = {}
                }
            end

            return nil
        end, lines)


        result = vim.tbl_filter(function(v)
            return v ~= nil
        end, temp)
    end

    return result
end

---@param line string
---@return boolean
---@return string | nil
---@return string | nil
local function parse_diff_header(line)
    local file_a, file_b = line:match("diff %-%-git a%/([^ ]*) b%/([^ ]*)")
    local ok = file_a ~= nil and file_b ~= nil

    return ok, file_a, file_b
end

---@param line string
---@return boolean
---@return string | nil
---@return string | nil
---@return string | nil
local function parse_diff_index(line)
    local commit_old, commit_new, file_mode = line:match("index ([a-zA-Z0-9]*)%.%.([a-zA-Z0-9]*) (%d*)")
    local ok = commit_old ~= nil and commit_new ~= nil and file_mode ~= nil

    return ok, commit_old, commit_new, file_mode
end

---@param line string
---@return boolean
---@return number | nil
---@return string | nil
local function parse_diff_start_head(line)
    local start_line, function_context = line:match("@@ %-(%d+),%d+ %+%d+,%d+ @@ (.*)")
    local ok = start_line ~= nil and function_context ~= nil

    return ok, tonumber(start_line), function_context
end


---@param lines string[]
---@return gitstatus.Hunk[] | nil
local function parse_diff(lines)
    ---@type gitstatus.Hunk[]
    local result = {}

    local step = "header"

    ---@type boolean
    local ok = false

    ---@type string | nil
    local file_a, file_b, commit_old, commit_new, file_mode, function_context

    ---@type number | nil
    local start_line

    ---@type gitstatus.Line[] | nil
    local content = nil

    for _, line in ipairs(lines) do
        vim.print(step)

        if step == "header" then
            ok, file_a, file_b = parse_diff_header(line)

            step = ok and "index" or "failed"
        elseif step == "index" then
            ok, commit_old, commit_new, file_mode = parse_diff_index(line)

            step = ok and "check_a" or "failed"
        elseif step == "check_a" then
            step = string.match(line, "--- a/" .. file_a) and "check_b" or "failed"
        elseif step == "check_b" then
            step = string.match(line, "+++ b/" .. file_b) and "body" or "failed"
        elseif step == "body" and line:match("^@@") then
            if content ~= nil and start_line ~= nil and file_a ~= nil then
                ---@type gitstatus.Hunk
                local hunk = {
                    content = content,
                    start_line = start_line,
                    details = {
                        file_a = file_a,
                        file_b = file_b,
                        commit_old = commit_old,
                        commit_new = commit_new,
                        file_mode = file_mode,
                        function_context = function_context
                    }
                }

                table.insert(result, hunk)
            end

            ok, start_line, function_context = parse_diff_start_head(line)
            content = {}
        elseif step == "body" and line:match("^%-") and content ~= nil then
            ---@type gitstatus.Line
            local temp = {
                line = line:sub(2),
                state = types.LINE_STATE.REMOVE,
            }

            table.insert(content, temp)
        elseif step == "body" and line:match("^%+") and content ~= nil then
            ---@type gitstatus.Line
            local temp = {
                line = line:sub(2),
                state = types.LINE_STATE.ADD,
            }

            table.insert(content, temp)
        elseif step == "body" and line:match("^ ") and content ~= nil then
            ---@type gitstatus.Line
            local temp = {
                line = line:sub(2),
                state = types.LINE_STATE.UNCHANGED,
            }

            table.insert(content, temp)
        elseif step == "end" then
            break
        elseif step == "failed" then
            vim.print("Failed to parse the diff.")

            return nil
        end
    end

    if content ~= nil and
        start_line ~= nil and
        file_a ~= nil and
        file_b ~= nil and
        commit_old ~= nil and
        commit_new ~= nil and
        file_mode ~= nil and
        function_context ~= nil
    then
        ---@type gitstatus.Hunk
        local hunk = {
            content = content,
            start_line = start_line,
            details = {
                file_a = file_a,
                file_b = file_b,
                commit_old = commit_old,
                commit_new = commit_new,
                file_mode = file_mode,
                function_context = function_context
            }
        }

        table.insert(result, hunk)
    end


    return result
end

---@param content string | nil
---@return gitstatus.Hunk[]
function M.get_diff_file_parsed(content)
    if content ~= nil then
        local lines = vim.split(content, "\n")

        local hunks = parse_diff(lines)

        if hunks ~= nil then
            return hunks
        else
            vim.print("Failed to parse diff: " .. lines[1])
        end
    end

    return {}
end

return M
