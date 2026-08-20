local M = {}

local BufferName = "[Github]"
local PRs = {}

local function find_buf_by_name(name)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local n = vim.api.nvim_buf_get_name(bufnr)

        if n == name or vim.fn.fnamemodify(n, ":t") == name then
            return bufnr
        end
    end

    return nil
end

local function render_screen(buf)
    vim.schedule(function()
        vim.bo.modifiable = true

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            "Github",
            "",
            "r - refresh all PRs",
            "w - open PR in web",
            "e - edit PR body",
            ""
        })

        for _, obj in ipairs(PRs) do
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                string.format("#%d (%s) - %s - %s", obj.number, obj.state, obj.author.name, obj.title)
            })
        end

        vim.bo.modifiable = false
        vim.bo.modified = false
    end)
end


local function get_all_PRs(buf)
    vim.system({ "gh", "pr", "list", "--json", "number,title,author,state" }, { text = true }, function(result)
        PRs = vim.json.decode(result.stdout)

        render_screen(buf)
    end)
end


local function render(buf)
    get_all_PRs(buf)

    vim.keymap.set("n", "r", function()
        get_all_PRs(buf)
    end, { buffer = true })

    vim.keymap.set("n", "w", function()
        local line = vim.api.nvim_get_current_line()
        local number = line:match("^#(%d+)")

        vim.system({ "gh", "pr", "view", number, "-w" })
        vim.print(number)
    end, { buffer = true })

    vim.keymap.set("n", "e", function()
        local line = vim.api.nvim_get_current_line()
        local number = line:match("^#(%d+)")

        vim.print(number)
        vim.system({ "gh", "pr", "view", number, "--json", "body" }, function(result)
            local body = vim.json.decode(result.stdout).body

            vim.schedule(function()
                vim.cmd("split")
                vim.cmd("enew")
                local buf_write = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_name(buf_write, "PR body")

                vim.api.nvim_buf_set_lines(buf_write, 0, -1, false, vim.split(body, "\r?\n"))
                vim.cmd("set ft=markdown")

                vim.api.nvim_create_autocmd("BufWriteCmd", {
                    buffer = buf_write,
                    callback = function()
                        local lines = vim.api.nvim_buf_get_lines(buf_write, 0, -1, false)
                        local new_body = table.concat(lines, "\n")

                        vim.fn.system({ "gh", "pr", "edit", number, "--body", new_body })

                        if vim.v.shell_error == 0 then
                            vim.bo.modified = false
                            vim.notify("PR body updated")
                        else
                            vim.notify("Failed to update PR body", vim.log.levels.ERROR)
                        end

                        vim.cmd("bdelete!")
                        vim.cmd("close")
                    end,
                })
            end)
        end)
    end, { buffer = true })
end

vim.keymap.set("n", "<leader>gh", function()
    local github_buf = find_buf_by_name(BufferName)

    if github_buf == nil then
        vim.cmd("enew")
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_name(buf, BufferName)

        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.swapfile = false
        vim.bo.modified = false
        vim.bo.buflisted = false

        render(buf)

        vim.bo.modified = false
        vim.bo.modifiable = false
    else
        vim.api.nvim_set_current_buf(github_buf)
    end
end, { desc = "Open github." })

vim.keymap.set("n", "<leader>tt", ":restart<CR>", {})

return M
