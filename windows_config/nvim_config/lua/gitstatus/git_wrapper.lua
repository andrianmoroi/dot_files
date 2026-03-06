local M = {}

local shell = require("gitstatus.shell")

---@param path string
---@param on_update fun(branch_name: string): nil
function M.update_branch(path, on_update)
    shell.run_async("git branch --show-current", path, function(data)
        on_update(data)
    end)
end

---@param path string
---@param on_update fun(lines: string[]): nil
function M.update_git_status(path, on_update)
    shell.run_async("git status --porcelain", path, function(data)
        local lines = vim.split(data, '\n')

        on_update(lines)
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
