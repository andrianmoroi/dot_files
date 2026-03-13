local M = {}

---@param repo_path string
---@param file_relative_path string
---@return gitstatus.Path
function get_path(repo_path, file_relative_path)
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

---@param content string | nil
---@param file_path string
---@return gitstatus.Hunk[]
function M.get_diff_file_parsed(content, file_path)
    ---@type gitstatus.Hunk[]
    local result = {}
    local display = string.find(file_path, "git_wrapper", 1, true) ~= nil
    vim.print(display)

    if content ~= nil then
        -- if content:match("Binary files") then
        --     return result
        -- end

        local lines = vim.split(content, "\n")
        ---@type gitstatus.Hunk | nil
        local current_hunk = nil


        for _, line in ipairs(lines) do
            local a, _, _, _ = line:match('^@@%s+%-(%d+),?(%d*)%s+%+(%d+),?(%d*)%s+@@')

            if a then
                local num_a = tonumber(a)

                if num_a ~= nil then
                    current_hunk = {
                        start_line = num_a,
                        new_content = {},
                        old_content = {},
                    }

                    table.insert(result, current_hunk)
                end
            else
                if current_hunk then
                    local first = line:sub(1, 1)

                    if first == ' ' then
                        table.insert(current_hunk.old_content, line:sub(2))
                        table.insert(current_hunk.new_content, line:sub(2))
                    elseif first == '-' then
                        table.insert(current_hunk.old_content, line:sub(2))
                    elseif first == '+' then
                        table.insert(current_hunk.new_content, line:sub(2))
                    else
                    end
                end
            end
        end
    end

    return result
end

return M
