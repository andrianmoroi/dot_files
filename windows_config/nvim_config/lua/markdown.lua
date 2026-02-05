local M = {}

local workspaces = {
    "~/notes"
}

function M.insert_markdown_link()
    local dir = vim.fn.expand("%:p:h")
    local linkName = vim.fn.input("Link name: ")
    local linkRelativePath = vim.fs.joinpath(linkName .. ".md")
    local linkFullPath = vim.fs.joinpath(dir, linkName .. ".md")

    -- 2. Create the file if it doesn't exist
    local linkDir = vim.fn.fnamemodify(linkFullPath, ":h")
    if linkDir ~= "." then
        vim.fn.mkdir(linkDir, "p")
    end

    if vim.fn.filereadable(linkFullPath) == 0 then
        local fd = io.open(linkFullPath, "w")
        if fd then
            fd:write("") -- empty file
            fd:close()
        end
    end

    local link = string.format("[%s](%s)", linkName, linkRelativePath)

    -- 4. Insert at cursor
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    col = col + 1
    local new_line =
        line:sub(1, col) .. link .. line:sub(col + 1)

    vim.api.nvim_set_current_line(new_line)

    -- 5. Move cursor to end of inserted link
    vim.api.nvim_win_set_cursor(0, { row, col + #link })
end

return M
