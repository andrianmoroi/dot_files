local M = {}

----------------------------------------
--- Shell commands
----------------------------------------

---@param cmd string
---@param cwd string
---@return string | nil
function M.run_sync(cmd, cwd)
    local cmd_table = vim.split(cmd, " ")
    local result = vim.system(cmd_table, { text = true, cwd = vim.trim(cwd) })
        :wait()

    if result.code ~= 0 then
        return nil
    end

    return result.stdout
end

---@param cmd string
---@param cwd string
---@param callback fun(stdout: string|nil)
---@return nil
function M.run_async(cmd, cwd, callback)
    local cmd_table = vim.split(cmd, " ")

    vim.system(cmd_table, { text = true, cwd = vim.trim(cwd) },
        function(result)
            if result.code ~= 0 then
                callback(nil)
                return
            end

            callback(result.stdout)
        end
    )
end

return M
