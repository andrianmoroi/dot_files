---@class State
---@field buf_id number
---@field is_loading boolean
---@field show_details boolean
---@field prs PR[]
---@field repo_name string

---@class PR
---@field id number
---@field author string
---@field state string
---@field title string
---@field reviewDecision string
---@field commits number
---@field changedFiles string
---@field additions string
---@field deletions string
---@field baseRefName string

local M = {}


return M
