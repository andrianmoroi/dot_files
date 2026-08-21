local M = {}

require("github.types")
local renderer = require("github.renderer")

---@type State
local state = {
    buf_id = -1,
    is_loading = false,
    prs = {}
}

---Update the list of prs
---@param prs any[]
function M.update_prs(prs)
    ---@type PR[]
    local state_prs = {}

    for _, obj in ipairs(prs) do
        ---@type PR
        local pr = {
            id = obj.number,
            author = obj.author.name,
            state = obj.state,
            title = obj.title
        }

        table.insert(state_prs, pr)
    end

    state.prs = state_prs
    state.is_loading = false

    renderer.render(state)
end

---Set loading state
function M.start_loading()
    state.is_loading = true

    renderer.render(state)
end

---Initialize the state module
---@param buf_id number
function M.init(buf_id)
    state.buf_id = buf_id

    renderer.render(state)
end

---Get the buffer id.
---@return number buffer_id
function M.get_buf_id()
    return state.buf_id
end

return M
