local M = {}

local shell = require("gitstatus.shell")
local git_parser = require("gitstatus.git_parser")

---@param path string
---@param on_update fun(branch_name: string|nil): nil
function M.update_branch(path, on_update)
    shell.run_async("git branch --show-current", path, function(data)
        on_update(data)
    end)
end

---@param path string
---@param on_update fun(lines: gitstatus.FileStatus[]): nil
function M.update_git_status(path, on_update)
    shell.run_async("git status --porcelain", path, function(data)
        local result = git_parser.get_parsed_git_status(path, data)

        for _, file_status in ipairs(result) do
            M.update_git_diff_file(path, file_status.path, function(hunks)
                vim.print(file_status.path.git_path)
                file_status.hunks = hunks

                on_update(result)
            end)
        end

        on_update(result)
    end)
end

---@param path string
---@param file_path gitstatus.Path
---@param on_update fun(hunks: gitstatus.Hunk[]): nil
function M.update_git_diff_file(path, file_path, on_update)
    shell.run_async("git diff --no-color --diff-algorithm=histogram -- " .. file_path.git_path, path, function(data)
        ---@type gitstatus.Diff[]
        local result = git_parser.get_diff_file_parsed(data, file_path)

        on_update(result)
    end)
end

---@param path string
---@param limit integer
---@param on_update fun(lines: GitCommit[]): nil
function M.update_git_last_commits(path, limit, on_update)
    shell.run_async(
        "git log -n " .. tostring(limit) .. " --pretty=format:\"%h|%an|%ar|%s\"", path, function(data)
            local result = {}

            if data ~= nil and #data > 0 then
                for _, line in ipairs(vim.split(data, '\n')) do
                    local hash, author, date, message = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")

                    if hash then
                        table.insert(result, {
                            hash = hash,
                            author = author,
                            date = date,
                            message = message,
                        })
                    end
                end
            end

            on_update(result)
        end)
end

return M
