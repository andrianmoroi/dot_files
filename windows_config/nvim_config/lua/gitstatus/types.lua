----------------------------------------
--- Types
----------------------------------------

---@class Remote
---@field fetch string
---@field push string

---@class RepoState
---@field name string
---@field path string
---@field on_change fun(repo: RepoState): nil
---@field branch string | nil
---@field remotes table<string, Remote>

---@class UpdateRepoState
---@field branch string | nil
---@field remotes table<string, Remote> | nil
---@field on_change nil | fun(repo: RepoState): nil

return {}
