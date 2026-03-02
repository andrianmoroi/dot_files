local M = {}

----------------------------------------
--- Helper functions
----------------------------------------

---Prints an error message
---@param message string
---@return nil
function M.error(message)
    vim.print("ERROR: " .. message)
end

---Checks if any of the expected_props exists in the updated_props.
---@param expected_props string[]
---@param updated_props string[]
---@return boolean
function M.any_props_updated(expected_props, updated_props)

    for _, expected in ipairs(updated_props) do
        if vim.tbl_contains(expected_props, expected) then
            return true
        end
    end

    return false
end

return M
