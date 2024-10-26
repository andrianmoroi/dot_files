-- [[ Setting options ]]
-- See `:help vim.opt`
-- import-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.cmdheight = 0

vim.g.have_nerd_font = true

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.mouse = "a" -- enables mouse support for all modes

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.cmd("set expandtab") -- use spaces for identation instead of tabs.

-- show an additional message when in Insert/Visual/Replace mode
-- no effect when cmdheight is 0
vim.opt.showmode = false

vim.opt.breakindent = true -- Keep same indenting for a new line
vim.opt.undofile = true -- save undo history in a file

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes" -- Keep signcolumn on by default

-- waiting milliseconds(after last typed characters) to write the swap file to disk.
vim.opt.updatetime = 250

-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

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
vim.opt.scrolloff = 30

vim.opt.colorcolumn = "80"
