local M = {}

local helper = require("gitstatus.helper")

----------------------------------------
--- Git repo state
----------------------------------------

---@type table<string, RepoState>
local GitReposState = {}

---@param repo_path string
---@param on_change_callback fun(RepoState): nil
---@return RepoState
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
---@return RepoState
function M.initialize_current_repo(repo_path, on_change_callback)
    local repo_state = get_new_repo_state(repo_path, on_change_callback)

    HEAD = repo_path
    GitReposState[repo_path] = repo_state

    return repo_state
end


---@return RepoState | nil
function M.get_current_repo()
    return get_repo_state(HEAD)
end


---@param repo_path string
---@param on_change_callback fun(repo: RepoState, props: UpdateRepoState): nil
---@return RepoState | nil
function M.initialize_current_repo_if_missing(repo_path, on_change_callback)
    if HEAD == nil then
        M.initialize_current_repo(repo_path, on_change_callback)
    end

    return M.get_current_repo()
end


---@param repo RepoState
---@param props UpdateRepoState
---@return RepoState
function M.update_repo(repo, props)

    local updated_repo = vim.tbl_extend("force", repo, props)
    local on_change = updated_repo["on_change"]

    if on_change ~= nil then
        on_change(updated_repo, props)
    else
        helper.error("on_change is missing.")
    end

    return updated_repo
end

---@param props UpdateRepoState
---@return nil
function M.update_current_repo(props)
    local curret_repo = M.get_current_repo()

    if curret_repo == nil or HEAD == nil then
        helper.error("The curent repo is not initialized.")

        return
    end

    local updated_repo = vim.tbl_extend("force", curret_repo, props)

    GitReposState[HEAD] = updated_repo

    local on_change = updated_repo["on_change"]

    if on_change ~= nil then
        on_change(updated_repo, props)
    else
        helper.error("on_change is missing.")
    end
end

---@return string | nil
function M.get_current_head()
    return HEAD
end

return M
