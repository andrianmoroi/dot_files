----------------------------------------
--- Types
----------------------------------------

---@class Remote
---@field fetch string
---@field push string

---@class FileStatus
---@field file_path string

---@class RepoState
---@field name string
---@field path string
---@field on_change fun(repo: RepoState): nil
---@field branch string | nil
---@field remotes table<string, Remote>
---@field status FileStatus[]
---@field commits GitCommit[]

---@class UpdateRepoState
---@field branch string | nil
---@field remotes table<string, Remote> | nil
---@field on_change nil | fun(repo: RepoState): nil
---@field status FileStatus[] | nil

---@class GitCommit
---@field hash string
---@field author string
---@field message string
---@field date string

return {}
