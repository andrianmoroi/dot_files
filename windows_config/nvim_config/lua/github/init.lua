local M = {}

local BufferName = "[Github]"

local state = require("github.state")

local function find_buf_by_name(name)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local n = vim.api.nvim_buf_get_name(bufnr)

        if n == name or vim.fn.fnamemodify(n, ":t") == name then
            return bufnr
        end
    end

    return nil
end

local function get_all_PRs()
    state.start_loading()

    vim.system({ "gh", "pr", "list", "--json", "number,title,author,state" }, { text = true }, function(result)
        local prs = vim.json.decode(result.stdout)

        state.update_prs(prs)
    end)
end


local function init_shortcuts()
    get_all_PRs()

    vim.keymap.set("n", "r", function()
        get_all_PRs()
    end, { buffer = true })

    vim.keymap.set("n", ")", function()
        vim.fn.search("^#\\d* *-", "W")
    end, { buffer = state.get_buf_id() })

    vim.keymap.set("n", "(", function()
        vim.fn.search("^#\\d* *-", "bW")
    end, { buffer = state.get_buf_id() })

    vim.keymap.set("n", "o", function()
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
        vim.bo.modifiable = false

        state.init(buf)

        init_shortcuts()
    else
        vim.api.nvim_set_current_buf(github_buf)
    end
end, { desc = "Open github." })

vim.keymap.set("n", "<leader>tt", ":restart<CR>", {})

return M
