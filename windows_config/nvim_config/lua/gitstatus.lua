local M = {}

----------------------------------------
--- Git command
----------------------------------------

local function git(cmd, cwd)
    local result = vim.system(
        vim.list_extend({ "git" }, cmd),
        { text = true, cwd = cwd }
    ):wait()

    if result.code ~= 0 then
        return nil
    end

    return vim.trim(result.stdout)
end


----------------------------------------
--- Git status
----------------------------------------

function M.open_page()
    vim.cmd("tabnew")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.bo[buf].filetype = "my_page"

    local cwd = vim.fn.getcwd()
    local branch = git({ "branch", "--show-current" }, cwd) or "not a repo"
    local status = git({ "status", "--porcelain" }, cwd) or ""

    local lines = {
        "🚀 My Interactive Page",
        "",
        "[1] Say Hello",
        "[2] Show Time",
        branch,
        "[q] Close",
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].modifiable = false

    local function map(key, fn)
        vim.keymap.set("n", key, fn, { buffer = buf, nowait = true })
    end

    map("1", function()
        print("Hello from interactive buffer!")
    end)

    map("2", function()
        print(os.date())
    end)

    map("q", function()
        vim.cmd("bd!")
    end)
end

return M
