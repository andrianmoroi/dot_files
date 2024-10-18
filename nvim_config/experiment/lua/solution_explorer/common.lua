local M = {}

function M.get_files_with_extension(dir, extension)
    local files = {}

    local handle = vim.loop.fs_scandir(dir)
    if not handle then
        print("Could not open directory: " .. dir)
        return files
    end

    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end

        if type == "file" and name:match("%." .. extension .. "$") then
            table.insert(files, dir .. "/" .. name)
        end
    end

    return files
end

function M.print_table(tbl, indent)
    if not indent then
        indent = 0
    end

    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            M.print_table(v, indent + 1)
        else
            print(formatting .. tostring(v))
        end
    end
end

return M
