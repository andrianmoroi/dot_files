local M = {}

local function parse(lines, index_line)
    local commentPrefix = "###"
    while lines[index_line]:sub(1, #commentPrefix) ~= commentPrefix and index_line > 1 do
        index_line = index_line - 1
    end

    while lines[index_line]:sub(1, #commentPrefix) == commentPrefix and index_line >= 1 do
        index_line = index_line + 1
    end

    local first = lines[index_line]
    assert(first, "Empty buffer")

    local method, url = first:match("^(%S+)%s+(%S+)$")
    assert(method and url, "First line must be: METHOD URL")

    local headers = {}
    local body = {}

    local in_body = false

    for i = index_line + 1, #lines do
        local line = lines[i]

        if not in_body then
            if line == "" then
                in_body = true
            else
                table.insert(headers, line)
            end
        else
            if line:sub(1, 3) == "---" then
                break
            end

            table.insert(body, line)
        end
    end

    local last = #body

    while last > 0 and body[last]:match("^$") do
        last = last - 1
    end

    for i = #body, last + 1, -1 do
        table.remove(body, i)
    end

    return method, url, headers, table.concat(body, "\n")
end

function M.send()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    local method, url, headers, body = parse(lines, current_line)

    local cmd = {
        "curl",
        -- "--ssl-revoke-best-effort",
        "-i",
        "-X", method,
    }

    for _, h in ipairs(headers) do
        table.insert(cmd, "-H")
        table.insert(cmd, h)
    end

    if body ~= "" then
        table.insert(cmd, "--data")
        table.insert(cmd, body)
    end

    table.insert(cmd, url)

    vim.system(cmd, { text = true }, function(result)
        vim.schedule(function()
            vim.cmd("vnew")

            local out = {}

            if result.stdout ~= "" then
                vim.list_extend(out, vim.split(result.stdout, "\n"))
            end

            -- if result.stderr ~= "" then
            --     table.insert(out, "")
            --     table.insert(out, "=== STDERR ===")
            --     vim.list_extend(out, vim.split(result.stderr, "\n"))
            -- end

            vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
            vim.bo.buftype = "nofile"
            vim.bo.filetype = "http"
            vim.bo.bufhidden = "wipe"
            vim.bo.swapfile = false
        end)
    end)
end

return M
