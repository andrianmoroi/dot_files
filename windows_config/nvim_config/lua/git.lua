local M = {}

----------------------------------------
--- Git mode
----------------------------------------

local function set_mode_enabled(isEnabled)
    vim.b.gitstatus_mode = isEnabled

    vim.api.nvim_command("redrawstatus")
end

local function enable_mode()
    set_mode_enabled(true)
end

local function disable_mode()
    set_mode_enabled(false)
end

function M.is_mode_enabled()
    return vim.b.gitstatus_mode
end

----------------------------------------
--- Gitsigns module
----------------------------------------

local gitsigns_cache

local function load_gitsigns()
    if not gitsigns_cache then
        gitsigns_cache = require("gitsigns")
    end

    return gitsigns_cache
end

----------------------------------------
--- Keymaps registering
----------------------------------------

local active_maps = {}

local function local_map(mode, lhs, rhs, desc)
    local opts = { desc = desc, buffer = true }

    vim.keymap.set(mode, lhs, rhs, opts)

    table.insert(active_maps, {
        mode = mode,
        lhs = lhs,
        opts = { buffer = true },
    })
end

local function clear_all_active_mappings()
    for _, m in ipairs(active_maps) do
        pcall(vim.keymap.del, m.mode, m.lhs, m.opts)
    end
end


----------------------------------------
--- Preview hunk
----------------------------------------

local previewId = 'hunk'
local showPreview = false

local function update_preview_state()
    showPreview = false

    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.w[winid].gitsigns_preview == previewId then
            showPreview = true
        end
    end
end

local function close_gitsigns_preview()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.w[winid].gitsigns_preview == previewId then
            pcall(vim.api.nvim_win_close, winid, true)
        end
    end
end

function M.toggle_preview_hunk()
    local gs = load_gitsigns()

    showPreview = not showPreview

    if showPreview then
        gs.preview_hunk()
    else
        close_gitsigns_preview()
    end
end

function M.enable_preview_hunk()
    if not showPreview then
        M.toggle_preview_hunk()
    end
end

----------------------------------------
--- Git actions
----------------------------------------

---@type Gitsigns.NavOpts
local gitsign_hunk_config = {
    count = 1,
    foldopen = true,
    greedy = false,
    navigation_message = true,
    target = "unstaged",
    wrap = true,
    preview = true
}

local function next()
    local gs = load_gitsigns()

    gs.nav_hunk("next", gitsign_hunk_config)
end

local function reset_hunk()
    local gs = load_gitsigns()

    gs.reset_hunk(nil, nil, function(err)
        -- gs.nav_hunk("next", gitsign_hunk_config)
    end)
end

local function stage_hunk()
    local gs = load_gitsigns()

    gs.stage_hunk(nil, nil, function(err)
        -- gs.nav_hunk("next", gitsign_hunk_config)
    end)
end

----------------------------------------
--- Setup git mode
----------------------------------------

function M.enable_git_mode()
    local gs = load_gitsigns()


    local exit_mode = function()
        clear_all_active_mappings()

        disable_mode()
    end

    update_preview_state()
    enable_mode()

    gs.nav_hunk("next", gitsign_hunk_config)

    local_map("n", "<M-j>", function() gs.nav_hunk("next", gitsign_hunk_config) end, "Next hunk.")
    local_map("n", "<M-k>", function() gs.nav_hunk("prev", gitsign_hunk_config) end, "Previous hunk.")
    local_map("n", "p", M.toggle_preview_hunk, "Previous hunk.")
    local_map("n", "r", reset_hunk, "Reset hunk.")
    local_map("n", "s", stage_hunk, "Stage hunk.")
    local_map("n", "d", gs.diffthis, "Diff this file.")

    local_map("n", "q", exit_mode, "Exit Git mode.")
    local_map("n", "<Esc>", exit_mode, "Exit Git mode.")
end

return M
