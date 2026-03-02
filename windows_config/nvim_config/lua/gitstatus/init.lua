local M = {}

require("gitstatus.types")


local helper = require("gitstatus.helper")
local repo_state = require("gitstatus.repo_state")
local shell = require("gitstatus.shell")
local renderer = require("gitstatus.renderer")

----------------------------------------
--- Initializing module
----------------------------------------

local function initialize_module()
    vim.print("Initializing git status module.")

    local current_cwd = vim.fn.getcwd()
    local repo_folder = shell.run_sync("git rev-parse --show-toplevel", current_cwd)

    if repo_folder == nil then
        helper.error("Cannot determine the repo folder.")

        return
    end

    local initialized_repo = repo_state.initialize_current_repo(repo_folder, function(repo, props)
        vim.schedule(function()
            renderer.render_buffer(repo, vim.tbl_keys(props))
        end)
    end)

    if initialized_repo == nil then
        helper.error("Failed to initiliaze the repo.")

        return
    end

    renderer.initialize_buffer()

    shell.run_async(
        "git branch --show-current",
        initialized_repo.path,
        function(data)
            repo_state.update_current_repo({ branch = data })
        end)

    shell.run_async("git remote -v", initialized_repo.path, function(data)
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
    end)
end



----------------------------------------
--- Git status
----------------------------------------

function M.open_page()
    initialize_module()


    local function map(key, fn)
        vim.keymap.set("n", key, fn, { buffer = renderer.get_buffer_id(), nowait = true })
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
