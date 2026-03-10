local M = {}

local shell = require("gitstatus.shell")

---@param path string
---@param on_update fun(branch_name: string|nil): nil
function M.update_branch(path, on_update)
    shell.run_async("git branch --show-current", path, function(data)
        on_update(data)
    end)
end

---@param path string
---@param on_update fun(lines: FileStatus[]): nil
function M.update_git_status(path, on_update)
    shell.run_async("git status --porcelain", path, function(data)
        ---@type FileStatus[]
        local result = {}

        if data ~= nil then
            local lines = vim.split(data, '\n')

            local temp = vim.tbl_map(function(line)
                if line ~= "" then
                    local status, file_path = line:match("^(..)%s(.+)$")

                    local sep = package.config:sub(1, 1)
                    local full_path = path .. sep .. file_path
                    full_path = full_path:gsub("[/\\]", sep)
                    local current_path = vim.fn.fnamemodify(full_path, ":~:.")


                    ---@type FileStatus
                    return {
                        full_path = full_path,
                        relative_cwd = current_path
                    }
                end

                return nil
            end, lines)


            result = vim.tbl_filter(function(v)
                return v ~= nil
            end, temp)
        end

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
