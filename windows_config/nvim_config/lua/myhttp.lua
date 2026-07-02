local M = {}

local function parse(lines)
    local first = lines[1]
    assert(first, "Empty buffer")

    local method, url = first:match("^(%S+)%s+(%S+)$")
    assert(method and url, "First line must be: METHOD URL")

    local headers = {}
    local body = {}

    local in_body = false

    for i = 2, #lines do
        local line = lines[i]

        if not in_body then
            if line == "" then
                in_body = true
            else
                table.insert(headers, line)
            end
        else
            table.insert(body, line)
        end
    end

    return method, url, headers, table.concat(body, "\n")
end

function M.send()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local method, url, headers, body = parse(lines)

    local cmd = {
        "curl",
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

            if result.stderr ~= "" then
                table.insert(out, "")
                table.insert(out, "=== STDERR ===")
                vim.list_extend(out, vim.split(result.stderr, "\n"))
            end

            vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
            vim.bo.buftype = "nofile"
            vim.bo.bufhidden = "wipe"
            vim.bo.swapfile = false
        end)
    end)
end

return M
