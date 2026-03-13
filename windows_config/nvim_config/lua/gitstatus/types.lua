local M = {}
----------------------------------------
--- Types
----------------------------------------

M.LINE_STATE = {
    UNDEFINED = 0,
    UNCHANGED = 1,
    REMOVE = 2,
    ADD = 3,
}


---@class gitstatus.Path
---@field git_path string
---@field full_path string
---@field cwd_relative_path string

---@class gitstatus.Line
---@field line string
---@field state number

---@class gitstatus.Hunk
---@field start_line number
---@field content gitstatus.Line[]
---@field old_content string[]
---@field new_content string[]

---@class gitstatus.Diff
---@field start_old_line number
---@field end_old_line number
---@field start_new_line number
---@field end_new_line number
---@field old_content string[]
---@field new_content string[]

---@class gitstatus.FileStatus
---@field path gitstatus.Path
---@field status string
---@field diffs gitstatus.Diff[]
---@field hunks gitstatus.Hunk[]

---@class gitstatus.Remote
---@field fetch string
---@field push string

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

return M
