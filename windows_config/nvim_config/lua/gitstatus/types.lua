----------------------------------------
--- Types
----------------------------------------

---@class gitstatus.Remote
---@field fetch string
---@field push string

---@class gitstatus.Diff
---@field start_old_line number
---@field end_old_line number
---@field start_new_line number
---@field end_new_line number
---@field old_content string[]
---@field new_content string[]

---@class gitstatus.FileStatus
---@field full_path string
---@field git_path string
---@field relative_cwd_path string
---@field status string
---@field diffs gitstatus.Diff[]

---@class gitstatus.GitCommit
---@field hash string
---@field author string
---@field message string
---@field date string

---@class gitstatus.RepoState
---@field name string
---@field path string
---@field on_change fun(repo: gitstatus.RepoState): nil
---@field branch string | nil
---@field remotes table<string, gitstatus.Remote>
---@field status gitstatus.FileStatus[]
---@field commits gitstatus.GitCommit[]

---@class gitstatus.UpdateRepoState
---@field branch string | nil
---@field remotes table<string, gitstatus.Remote> | nil
---@field on_change nil | fun(repo: gitstatus.RepoState): nil
---@field status gitstatus.FileStatus[] | nil
---@field commits gitstatus.GitCommit[] | nil

return {}
