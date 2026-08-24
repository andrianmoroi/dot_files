local M = {}

require("github.types")
local state = require("github.state")

---Toggle details for all PRs
function M.toggle_pr_details()
    state.toggle_details()
end

---Load all PRs
function M.load_all_prs()
    state.start_loading()

    vim.system({
            "gh",
            "pr",
            "list",
            "--json",
            "number,title,author,state,reviewDecision,commits,changedFiles,additions,deletions,baseRefName"
        },
        { text = true }, function(result)
            local prs = vim.json.decode(result.stdout)

            state.update_prs(prs)
        end)
end

return M
