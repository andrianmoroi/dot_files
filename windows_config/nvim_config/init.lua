--------------------------------------------------------------------------------
--- Leader key
--------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------------------------------------
--- Load lazy.nvim
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)


--------------------------------------------------------------------------------
--- Options
--------------------------------------------------------------------------------

vim.o.winborder = "rounded"

vim.opt.shell = "powershell"
vim.opt.shellcmdflag = "-c"
vim.opt.cmdheight = 0

vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a" -- enables mouse support for all modes

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.cmd("set expandtab") -- use spaces for identation instead of tabs.

-- show an additional message when in Insert/Visual/Replace mode
-- no effect when cmdheight is 0
vim.opt.showmode = false

vim.opt.breakindent = true -- Keep same indenting for a new line
vim.opt.undofile = true    -- save undo history in a file

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes" -- Keep signcolumn on by default

-- waiting milliseconds(after last typed characters) to write the swap file to disk.
vim.opt.updatetime = 250

-- Displays which-key popup sooner
vim.opt.timeoutlen = 3000
vim.opt.ttimeoutlen = 0

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 18

vim.opt.colorcolumn = "80"

vim.opt.completeopt = "menu,menuone,noinsert,noselect"

--------------------------------------------------------------------------------
--- Setup lazy
--------------------------------------------------------------------------------
require("lazy").setup({

    {
        "rebelot/kanagawa.nvim",
        opts = {
            compile = false,  -- enable compiling the colorscheme
            undercurl = true, -- enable undercurls
            commentStyle = { italic = true },
            functionStyle = {},
            keywordStyle = { italic = true },
            statementStyle = { bold = true },
            typeStyle = {},
            transparent = true,    -- do not set background color
            dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
            terminalColors = true, -- define vim.g.terminal_color_{0,17}
            colors = {             -- add/modify theme and palette colors
                palette = {},
                theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
            },
            theme = "wave",    -- Load "wave" theme
            background = {     -- map the value of 'background' option to a theme
                dark = "wave", -- try "dragon" !
                light = "lotus"
            },
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)

            vim.cmd("colorscheme kanagawa")

            vim.cmd [[highlight Visual guibg=#525249]]
            vim.cmd [[highlight CurSearch cterm=bold gui=bold guifg=#dcd7ba guibg=#525249]]
        end
    },

    { "echasnovski/mini.icons",      opts = {} },
    { "nvim-tree/nvim-web-devicons", opts = {} },

    {
        "echasnovski/mini.files",
        version = '*',
        opts = {
            mappings = {
                -- close = '<C-e>'
                go_in_plus = "<Enter>"
            },
            windows = {
                preview = true,
                width_preview = 50,
            },
        }
    },
    { "echasnovski/mini.pick",   opts = {} },
    {
        "echasnovski/mini.surround",
        opts = {
            -- Module mappings. Use `''` (empty string) to disable one.
            mappings = {
                add = 'sa',            -- Add surrounding in Normal and Visual modes
                delete = 'sd',         -- Delete surrounding
                find = 'sf',           -- Find surrounding (to the right)
                find_left = 'sF',      -- Find surrounding (to the left)
                highlight = 'sh',      -- Highlight surrounding
                replace = 'sr',        -- Replace surrounding
                update_n_lines = 'sn', -- Update `n_lines`

                suffix_last = 'l',     -- Suffix to search with "prev" method
                suffix_next = 'n',     -- Suffix to search with "next" method
            },
        }
    },
    {
        "echasnovski/mini.statusline",
        opts = {
            use_icons = vim.g.have_nerd_font,
            set_vim_settings = true,
            content = {
                active = function()
                    local miniStatusLine = require("mini.statusline")

                    local fileformat_icon = function()
                        local icons = { unix = ' LF', dos = ' CRLF', mac = ' CR' }
                        return icons[vim.bo.fileformat] or vim.bo.fileformat
                    end

                    local mode, mode_hl   = miniStatusLine.section_mode({ trunc_width = 1000000 })
                    local fileStatus      = vim.bo.modified and "*" or ""
                    local fileinfo        = miniStatusLine.section_fileinfo({ trunc_width = 1000000 })
                    -- local location      = '%P %l[%L]:%2v[%-2{virtcol("$") - 1}]'
                    local location        = '%P of %L'
                    local search          = miniStatusLine.section_searchcount({ trunc_width = 10 })
                    local lsp             = miniStatusLine.section_lsp({ trunc_width = 75 })
                    local diagnostics     = miniStatusLine.section_diagnostics({ trunc_width = 75 })

                    local size            = vim.fn.getfsize(vim.fn.getreg('%'))
                    local sizeFormat      = ""
                    local spell           = vim.api.nvim_get_option_value("spell", {}) and " " or ""

                    if size < 0 then
                        sizeFormat = ""
                    elseif size < 1024 then
                        sizeFormat = string.format('%d B', size)
                    elseif size < 1048576 then
                        sizeFormat = string.format('%.2f KiB', size / 1024)
                    else
                        sizeFormat = string.format('%.2f MiB', size / 1048576)
                    end

                    return miniStatusLine.combine_groups({
                        { hl = mode_hl,                  strings = { mode } },
                        '%<', -- Mark general truncate point
                        { hl = 'MiniStatuslineDevinfo',  strings = { diagnostics, spell, lsp } },
                        { hl = 'MiniStatuslineFilename', strings = { "%{expand('%:~:.')}", fileStatus } },
                        '%=', -- End left alignment
                        { hl = 'MiniStatuslineDevinfo',  strings = { vim.fn.reg_recording() ~= "" and "Recording: " .. vim.fn.reg_recording() or "" } },
                        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo, sizeFormat, fileformat_icon() } },
                        '%<', -- Mark general truncate point
                        { hl = mode_hl, strings = { search, location } },
                    })
                end,
                inactive = function()
                    return "%{expand('%:~:.')}"
                end
            }
        }
    },

    { "lewis6991/gitsigns.nvim", opts = {} },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
        },
    },

    { "folke/zen-mode.nvim", opts = {} },

    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'master',
        lazy = false,
        build = ":TSUpdate"
    },

})


--------------------------------------------------------------------------------
--- Keymaps
--------------------------------------------------------------------------------

local map = function(mode, key, action, description)
    vim.keymap.set(mode, key, action, { desc = description })
end

map('n', "<leader>w", ":w!<CR>", "Save file.")
map('n', "<M-q>", ":q<CR>", "Close window.")
map('n', "<Esc>", ":nohlsearch<CR>", "Disable highlight search.")
map('n', "<Tab>", ":bnext<CR>", "Switch to next buffer.")
map('n', "<S-Tab>", ":bprevious<CR>", "Switch to previous buffer.")
map('n', "<leader>q", ":bdelete<CR>", "Close buffer.")
map('n', "<C-n>", ":enew<CR>", "New empty buffer.")
map('n', "<C-w>n", ":vnew<CR>", "New vertical empty buffer.")
map('n', "<C-j>", ":cnext<CR>", "Next quickfix bookmark.")
map('n', "<C-k>", ":cprevious<CR>", "Previous quickfix bookmark.")
map('n', "<leader>cf", function() vim.lsp.buf.format() end, "Format code.")
map('n', "<leader>do", function() vim.diagnostic.open_float() end, "Open diagnostics window.")
map('n', "<leader>dq", function() vim.diagnostic.setqflist() end, "Send diagnostics to quick fix list.")
map('n', "<leader>dn", function() vim.diagnostic.goto_next() end, "Go to next diagnostic.")
map('n', "<leader>dp", function() vim.diagnostic.goto_prev() end, "Go to previous diagnostic.")

map('n', "<leader>r", ":%s/\\v", "Replace.")
map({'x', 'v'}, "<leader>r", ":s/\\v", "Replace.")

map('i', "<S-Tab>", "<C-V><Tab>", "Insert tab character.")

map('t', "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode.")

map({ 'n', 'x' }, "<leader>y", "\"+y", "Copy to clipboard.")
map({ 'n', 'x' }, "<leader>p", "\"+p", "Paste from clipboard.")
map({ 'n', 'x' }, "<leader>P", "\"+P", "Paste from clipboard.")

map('n', "<C-e>", function() require("mini.files").open() end, "Open file explorer.")
map('n', "<C-p>", function() require("mini.pick").builtin.files() end, "Search by file names.")
map('n', "<leader>sg", function() require("mini.pick").builtin.grep_live() end, "Search in files.")
map('n', "<leader>sh", function() require("mini.pick").builtin.help() end, "Search healp.")

--------------------------------------------------------------------------------
--- Highlight yanked text
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})


--------------------------------------------------------------------------------
--- LSP
--------------------------------------------------------------------------------

-- lua-language-server
vim.lsp.config['luals'] = {
    cmd = { os.getenv("LUA_LANGUAGE_SERVER") or "lua-language-server.exe" },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc' },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            runtime = {
                version = 'LuaJIT',
            }
        }
    }
}
vim.lsp.enable('luals')

-- csharp
vim.lsp.config['csharpls'] = {
    cmd = { 'csharp-ls' },
    filetypes = { 'cs' },
    init_options = {
        AutomaticWorkspaceInit = true,
    },
}
vim.lsp.enable('csharpls')


--------------------------------------------------------------------------------
--- Treesitter
--------------------------------------------------------------------------------

require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "lua" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}
