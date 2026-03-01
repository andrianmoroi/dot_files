local M = {}

----------------------------------------
--- Helper functions
----------------------------------------

---Prints an error message
---@param message string
---@return nil
local function error(message)
    vim.print("ERROR: " .. message)
end

----------------------------------------
--- Types
----------------------------------------

---@class RepoState
---@field name string
---@field path string
---@field branch string | nil
---@field on_change function(RepoState): nil

---@class UpdateRepoState
---@field branch string | nil
---@field on_change nil | function(RepoState): nil

----------------------------------------
--- Git repo state
----------------------------------------

---@type table<string, RepoState>
local GitReposState = {}

---@param repo_path string
---@param on_change_callback function(RepoState): nil
---@return nil
local function get_new_repo_state(repo_path, on_change_callback)
    local name = vim.fs.basename(repo_path)

    return {
        name = name,
        path = repo_path,
        on_change = on_change_callback
    }
end

---@param repo_name string | nil
---@return RepoState | nil
local function get_repo_state(repo_name)
    if repo_name == nil then
        return nil
    end

    return GitReposState[repo_name]
end

local HEAD = nil

---@param repo_path string
---@param on_change_callback fun(repo: RepoState, props: UpdateRepoState): nil
---@return table | nil
local function initialize_current_repo(repo_path, on_change_callback)
    local repo_state = get_new_repo_state(repo_path, on_change_callback)

    GitReposState[repo_path] = repo_state

    HEAD = repo_path

    return repo_state
end

---@return RepoState | nil
local function get_current_repo()
    return get_repo_state(HEAD)
end

---@param props UpdateRepoState
---@return nil
local function update_current_repo(props)
    local curret_repo = get_current_repo()

    if curret_repo == nil or HEAD == nil then
        error("The curent repo is not initialized.")

        return
    end

    local updated_repo = vim.tbl_extend("force", curret_repo, props)

    GitReposState[HEAD] = updated_repo

    local on_change = updated_repo["on_change"]

    if on_change ~= nil then
        on_change(updated_repo, props)
    else
        error("on_change is missing.")
    end
end

----------------------------------------
--- Shell commands
----------------------------------------

---@param cmd string
---@param cwd string
---@return string | nil
local function run_sync(cmd, cwd)
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
local function run_async(cmd, cwd, callback)
    local cmd_table = vim.split(cmd, " ")

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

---@param cmd string
---@return string | nil
local function run_head_sync(cmd)
    if HEAD == nil then
        error("Cannot run cmd, HEAD is null.")
    end

    return run_sync(cmd, HEAD)
end

---@param cmd string
---@param callback function
---@return nil
local function run_head_async(cmd, callback)
    if HEAD == nil then
        error("Cannot run cmd, HEAD is null.")
    end

    run_async(cmd, HEAD, callback)
end

----------------------------------------
--- Render buffer
----------------------------------------

---@class DrawArea
---@field header {startLine: number, endLine: number}

---@type number
local DrawBufferId = nil

---@type DrawArea
local DrawArea = {
    header = { startLine = 0, endLine = 0, },
}


---@param repo RepoState
---@return string[]
local function get_header_content(repo)
    local name = repo.name
    local branch = repo.branch

    return {
        "Git repository: " .. name,
        "",
        "Branch: " .. (branch or ""),
    }
end



---@param repo RepoState | nil
---@param update_props string[] | nil
---@return nil
local function render_buffer(repo, update_props)
    if repo == nil then
        error("Cannot render a nil repo.")
        return
    end

    vim.bo[DrawBufferId].modifiable = true

    vim.api.nvim_buf_set_lines(DrawBufferId, 0, -1, false, get_header_content(repo))


    -- local branch = ""   -- git({ "branch", "--show-current" }, cwd) or "not a repo"
    -- local myStatus = "" --git({ "status", "--porcelain" }, cwd) or ""
    -- local status = vim.split(myStatus, '\n')
    --
    -- local lines = {
    --     "🚀 Test",
    --     "",
    --     "[1] Say Hello",
    --     "[2] Show Time",
    --     branch,
    --     "[q] Close",
    -- }
    --




    vim.bo[DrawBufferId].modifiable = false
end


local function initialize_buffer()
    vim.cmd("tabnew")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "my_page"

    DrawBufferId = buf

    render_buffer(get_current_repo())
end

----------------------------------------
--- Initializing module
----------------------------------------

local function initialize_module()
    vim.print("Initializing git status module.")

    local current_cwd = vim.fn.getcwd()
    local repo_folder = run_sync("git rev-parse --show-toplevel", current_cwd)

    if repo_folder == nil then
        error("Cannot determine the repo folder.")

        return
    end

    local repo = initialize_current_repo(repo_folder, function(repo, props)
        vim.schedule(function()
            render_buffer(repo, vim.tbl_keys(props))
        end)
    end)

    if repo == nil then
        error("Failed to initiliaze the repo.")

        return
    end

    run_head_async("git branch --show-current", function(data)
        update_current_repo({ branch = data })
    end)
end



----------------------------------------
--- Git status
----------------------------------------

function M.open_page()
    initialize_module()
    initialize_buffer()


    local function map(key, fn)
        vim.keymap.set("n", key, fn, { buffer = DrawBufferId, nowait = true })
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
