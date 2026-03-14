local M = {}

local helper = require("gitstatus.helper")
local repo_state = require("gitstatus.repo_state")
local shell = require("gitstatus.shell")
local renderer = require("gitstatus.renderer")
local git_wrapper = require("gitstatus.git_wrapper")
local types = require("gitstatus.types")

----------------------------------------
--- Initializing module
----------------------------------------

---@type gitstatus.Hunk[]
local all_hunks = {}
local hunk_index = 0

local function initialize_module()
    local current_cwd = vim.fn.getcwd()
    local repo_folder = vim.trim(shell.run_sync("git rev-parse --show-toplevel", current_cwd) or "")

    if repo_folder == nil then
        helper.error("Cannot determine the repo folder.")

        return
    end

    local initialized_repo = repo_state.initialize_current_repo_if_missing(repo_folder, function(repo, props)
        vim.schedule(function()
            if repo ~= nil and repo.status ~= nil then
                all_hunks = {}

                for _, fs in ipairs(repo.status) do
                    for _, h in ipairs(fs.hunks) do
                        all_hunks[#all_hunks + 1] = h
                    end
                end
            end

            vim.print(#all_hunks)

            renderer.render_buffer(repo, vim.tbl_keys(props))
        end)
    end)


    if initialized_repo == nil then
        helper.error("Failed to initiliaze the repo.")

        return
    end

    renderer.initialize_buffer()

    local path = initialized_repo.path

    git_wrapper.update_branch(path, function(branch_name)
        if branch_name ~= nil then
            repo_state.update_current_repo({ branch = vim.trim(branch_name) })
        end
    end)

    git_wrapper.update_git_status(path, function(status)
        repo_state.update_current_repo({ status = status })
    end)

    git_wrapper.update_git_last_commits(path, 10, function(commits)
        repo_state.update_current_repo({ commits = commits })
    end)

    if initialized_repo ~= nil then
        renderer.render_buffer(initialized_repo, vim.tbl_keys(initialized_repo))


        shell.run_async("git remote -v", initialized_repo.path, function(data)
            if data ~= nil then
                local lines = vim.split(data, "\n")
                local remotes = {}

                for _, line in ipairs(lines) do
                    local name, url, typ = line:match("^(%S+)%s+(%S+)%s+%((%w+)%)$")
                    if name and url and typ then
                        remotes[name] = remotes[name] or {}
                        remotes[name][typ] = url
                    end
                end

                repo_state.update_current_repo({ remotes = remotes })
                repo_state.update_current_repo({})
            end
        end)
    end
end

function M.next_hunk()
    if all_hunks ~= nil and #all_hunks > 0 then
        hunk_index = hunk_index % #all_hunks + 1

        local hunk = all_hunks[hunk_index]

        vim.cmd("e +" .. hunk.start_line .. " " .. hunk.path.cwd_relative_path)

        -- vim.print(all_hunks[hunk_index])

        -- for _, status in ipairs(repo.status) do
        --     -- vim.print(status)
        -- end
    end
end

function M.prev_hunk()
    if all_hunks ~= nil and #all_hunks > 0 then
        hunk_index = (hunk_index + #all_hunks - 2) % #all_hunks + 1
        vim.print(hunk_index)

        local hunk = all_hunks[hunk_index]

        vim.cmd("e +" .. hunk.start_line .. " " .. hunk.path.cwd_relative_path)

        -- vim.print(all_hunks[hunk_index])

        -- for _, status in ipairs(repo.status) do
        --     -- vim.print(status)
        -- end
    end
end

----------------------------------------
--- Git status
----------------------------------------

function M.open_page()
    initialize_module()

    local function map(key, fn)
        vim.keymap.set("n", key, fn, { buffer = renderer.get_buffer_id(), nowait = true })
    end

    map("q", function()
        vim.cmd("bd!")
    end)
end

return M
