local M = {}

----------------------------------------
--- Shell commands
----------------------------------------

---@param cmd string
---@param cwd string
---@return string | nil
function M.run_sync(cmd, cwd)
    local cmd_table = vim.split(cmd, " ")
    local result = vim.system(cmd_table, { text = true, cwd = cwd })
        :wait()

    if result.code ~= 0 then
        return nil
    end

    return vim.trim(result.stdout)
end

---@param cmd string
---@param cwd string
---@param callback function
---@return nil
function M.run_async(cmd, cwd, callback)
    local cmd_table = vim.split(cmd, " ")

    vim.print(cmd_table)

    vim.system(cmd_table, { text = true, cwd = cwd },
        function(result)
            if result.code ~= 0 then
                callback(nil)
                return
            end

            callback(vim.trim(result.stdout))
        end
    )
end

return M
