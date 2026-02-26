local M = {}

----------------------------------------
--- Git mode
----------------------------------------

local GIT_MODE = false

local function set_mode_enabled(isEnabled)
    GIT_MODE = isEnabled

    vim.api.nvim_command("redrawstatus")
end

local function enable_mode()
    set_mode_enabled(true)
end

local function disable_mode()
    set_mode_enabled(false)
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

local showPreview = false

local function close_gitsigns_preview()
    local id = 'hunk'

    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.w[winid].gitsigns_preview == id then
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
--- Setup git mode
----------------------------------------

function M.enable_git_mode()
    local gs = load_gitsigns()

    local exit_mode = function()
        clear_all_active_mappings()

        disable_mode()
    end

    enable_mode()

    M.enable_preview_hunk()

    local_map("n", "j", gs.next_hunk, "Next hunk.")
    local_map("n", "k", gs.prev_hunk, "Previous hunk.")
    local_map("n", "p", M.toggle_preview_hunk, "Previous hunk.")
    local_map("n", "r", gs.reset_hunk, "Reset hunk.")
    local_map("n", "s", gs.stage_hunk, "Stage hunk.")
    local_map("n", "d", gs.diffthis, "Diff this file.")

    local_map("n", "q", exit_mode, "Exit Git mode.")
    local_map("n", "<Esc>", exit_mode, "Exit Git mode.")
end

function M.is_mode_enabled()
    return GIT_MODE
end

return M
