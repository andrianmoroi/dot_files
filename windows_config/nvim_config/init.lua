-------------------------------------------------------
--- TODOs
-------------------------------------------------------

--- TODO[AM] split lsp config into multiple files

-------------------------------------------------------
--- Leader key
-------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("configs.ui2")
require("configs.shell")

-------------------------------------------------------
--- Options
-------------------------------------------------------

vim.o.winborder        = "rounded"

vim.opt.shellcmdflag   = "-c"
vim.opt.cmdheight      = 1

vim.g.have_nerd_font   = true
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.mouse          = "a" -- enables mouse support for all modes

vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
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
vim.opt.swapfile = false
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

local default_scrolloff = 3
local center_scrolloff = 1000

local toggle_center_scroll = function()
    local total = default_scrolloff + center_scrolloff

    ---@diagnostic disable-next-line
    local current = vim.opt.scrolloff:get()

    vim.opt.scrolloff = total - current
end

vim.opt.scrolloff = default_scrolloff


local text_width = 100
vim.opt.colorcolumn = tostring(text_width)
vim.opt.textwidth = text_width

-- the histogram diff algorithm for diff operations
vim.opt.diffopt:append("algorithm:histogram")

function _G.custom_foldtext()
    local start_line = vim.fn.getline(vim.v.foldstart)
    local lines = vim.v.foldend - vim.v.foldstart + 1

    return string.format("▸%s  (%d lines)  ◂", start_line, lines)
end

vim.opt.foldtext = "v:lua.custom_foldtext()"
vim.opt.foldcolumn = "1"
vim.opt.fillchars = {
    fold = " "
}


-------------------------------------------------------
--- Disable unused providers
-------------------------------------------------------

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-------------------------------------------------------
--- Load vim.pack
-------------------------------------------------------

vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim", -- need for nvim-treesitter

    "https://github.com/tpope/vim-fugitive",
    "https://github.com/lewis6991/gitsigns.nvim",

    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/folke/which-key.nvim",

    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main"
    },

}, { load = true })

require("configs.colorscheme")


local mini = require("configs.mini")



-------------------------------------------------------
--- Gitsings
-------------------------------------------------------

local gitsings = require("gitsigns")

gitsings.setup({
    diff_opts = {
        internal = false,
    },
    update_debounce = 10,
    gh = true,
})

-------------------------------------------------------
--- Treesitter
-------------------------------------------------------

require("nvim-treesitter").install({ "c_sharp", "javascript", "typescript", "jsx", "tsx", "html", "css" })

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'typescript', 'json', 'jsx', 'tsx', 'html' },
    callback = function()
        vim.treesitter.start()
    end,
})

require("nvim-treesitter").update()


-------------------------------------------------------
--- Setup other plugins
-------------------------------------------------------

require("which-key").setup({ preset = "helix" })

-------------------------------------------------------
--- Keymaps
-------------------------------------------------------

local map = function(mode, key, action, description)
    vim.keymap.set(mode, key, action, { desc = description })
end

map('n', "<leader>w", ":w!<CR>", "Save file.")
map('n', "<M-q>", ":close<CR>", "Close window.")
map('n', "<Esc>", ":nohlsearch<CR>", "Disable highlight search.")
map('n', "<Tab>", ":bprevious<CR>", "Switch to next buffer.")
map('n', "<S-Tab>", ":bnext<CR>", "Switch to previous buffer.")
map('n', "<leader>q", ":bdelete<CR>", "Close buffer.")
-- map('n', "<leader>q", ":bprev<bar>bdelete #<CR>", "Close buffer.")
map('n', "<leader>Q", ":bdelete!<CR>", "Close buffer.")
map('n', "<C-n>", ":enew<CR>", "New empty buffer.")
map('n', "<C-w>n", ":vnew<CR>", "New vertical empty buffer.")
map('n', "<C-j>", ":cnext<CR>", "Next quickfix bookmark.")
map('n', "<C-k>", ":cprevious<CR>", "Previous quickfix bookmark.")
map('n', "<M-j>", "zj", "Next fold.")
map('n', "<M-k>", "zk", "Previous fold.")
map('n', "<leader>cf", vim.lsp.buf.format, "Format code.")
map('n', "<leader>cs", ":set spell!<CR>", "Toggle spell checking.")
map('n', "<leader>vct", toggle_center_scroll, "Toggle center scroll.")
map('n', "gd", vim.lsp.buf.definition, "Go to definition.")

map('n', "<leader>do", vim.diagnostic.open_float, "Open diagnostics window.")
map('n', "<leader>dq", vim.diagnostic.setqflist, "Send diagnostics to quick fix list.")
map('n', "<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Go to next diagnostic.")
map('n', "<leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Go to previous diagnostic.")
map('n', "<leader>dw", ":DotnetLoadErrors<CR>", "Load diagnostics from `dotnet watch` command.")

map('n', "<leader>r", ":%s/", "Replace.")
map({ 'x', 'v' }, "<leader>r", ":s/", "Replace.")

map('i', "<S-Tab>", "<C-V><Tab>", "Insert tab character.")

map('t', "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode.")

map({ 'n', 'x' }, "<leader>y", "\"+y", "Copy to clipboard.")
map({ 'n', 'x' }, "<leader>p", "\"+p", "Paste from clipboard.")
map({ 'n', 'x' }, "<leader>P", "\"+P", "Paste from clipboard.")

map({ 'n' }, "<leader>ct", "A  // TODO[AM]: ", "Apped a todo comment at the end of the line.")
map({ 'n' }, "<leader>cT", "O// TODO[AM]: ", "Add a todo comment one line above.")

map('n', "<M-e>", mini.files.open, "Open file explorer.")

map('n', "<M-p>", function()
    local show_with_icons = function(buf_id, items, query)
        mini.picker.default_show(buf_id, items, query, { show_icons = true })
    end

    local opts = {
        source = {
            name = "Files:",
            show = show_with_icons
        },
        window = {
            config = { height = 25 }
        }
    }

    mini.picker.builtin.cli({
        command = { "rg", "--files", "--hidden", "--no-follow", "--no-ignore-vcs", "--color=never", "--ignore-case" },
    }, opts)
end, "Search by file names.")
map('n', "<M-e>", mini.files.open, "Open file explorer.")
map('n', "<leader>sg", mini.picker.builtin.grep_live, "Search in files.")
map('n', "<leader>sh", mini.picker.builtin.help, "Search help.")
map('n', "<leader>sb", mini.picker.builtin.buffers, "Search buffers.")
map('n', "<leader>st", function()
    vim.cmd("copen")
    local current_cwd = vim.fn.getcwd()

    vim.system({
            "rg", "--vimgrep", "--hidden", "--no-follow", "--no-ignore-vcs", "--color=never", "--ignore-case",
            "TODO\\[.*AM\\]"
        }, { text = true, cwd = current_cwd },
        function(result)
            if result.code ~= 0 then
                vim.print("Failed to retrieve todos.")

                return
            end

            local results = vim.split(vim.trim(result.stdout), "\n")

            vim.schedule(function()
                vim.fn.setqflist({}, " ", {
                    title = "Ripgrep TODO.AM",
                    lines = results,
                    efm = "%f:%l:%c:%m"
                })
            end)
        end
    )
end, "Search TODOs.")

map('n', "<leader>sH", function()
    local docs_path = vim.fn.fnamemodify(vim.opt.helpfile:get(), ":h")

    local opts = {
        source = {
            name = "Documentation:",
            cwd = docs_path
        }
    }

    return mini.picker.builtin.grep_live(nil, opts)
end, "Search healp.")

map('n', "<leader>gg", ":0G<CR>", "Git show status.")
map('n', "<leader>bq", ":bufdo bdelete<CR>", "Close all buffers.")

map('n', "<leader>gs", gitsings.stage_hunk, "Git stage hunk.")
map('n', "<leader>ga", gitsings.stage_buffer, "Git stage entire buffer.")
map('n', "<leader>gq", gitsings.setqflist, "Git move all hunks to quickfix list.")
map('n', "<leader>gb", gitsings.blame, "Git blame this file.")
map('n', "<leader>gr", gitsings.reset_hunk, "Git reset hunk.")
map('n', "<leader>gp", require("git").toggle_preview_hunk, "Git toggle preview hunk.")

---@type Gitsigns.NavOpts
local gitsign_hunk_config = {
    count = 1,
    foldopen = true,
    greedy = true,
    navigation_message = true,
    target = "all",
    wrap = true,
    preview = true
}

map('n', "<leader>gn", function() gitsings.nav_hunk("next", gitsign_hunk_config) end,
    "Git move to next hunk.")
map('n', "<leader>gN", function() gitsings.nav_hunk("prev", gitsign_hunk_config) end,
    "Git move to previous hunk.")

map({ 'n', 'v' }, "grx", ":LspTypescriptSourceAction<CR>", "Typescript specific actions.")

-------------------------------------------------------
--- Highlight yanked text
-------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})


-------------------------------------------------------
--- LSP
-------------------------------------------------------

-- To install run:
-- scoop install lua-language-server

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
            },
            telemetry = {
                enable = false
            },
            workspace = {

                -- Only include the Lua stdlib and Neovim API types, not all runtime files
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.stdpath("config") .. "/lua",
                    vim.fn.stdpath("data") .. "site/pack/core/opt/",
                },
                checkThirdParty = false,
            },
        }
    }
}


-- To install run:
-- Go to
-- https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl/NuGet/Microsoft.CodeAnalysis.LanguageServer.<platform>/overview
-- replace <platform> with one of the following linux-x64, osx-x64, win-x64, neutral.
-- Download and extract it (nuget's are zip files).

require("dotnetLspRoslyn")



-- To install run:
-- npm i -g vscode-langservers-extracted

vim.lsp.config["html"] = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html', 'xml' },
    root_markers = { 'package.json', '.git' },
    init_options = {
        provideFormatter = true,
        embeddedLanguages = { css = true, javascript = true },
        configurationSection = { 'html', 'css', 'javascript' },
    },
    settings = {
        html = {
            format = {
                wrapAttributes = "auto",
                -- you can also set max line width if needed
                -- wrapLineLength = 120,
            }
        }
    }
}

-- To install run:
-- npm i -g typescript typescript-language-server

vim.lsp.config["typescript"] = {
    init_options = { hostInfo = 'neovim' },
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {
        'javascript',
        'javascriptreact',
        -- 'javascript.jsx',
        'typescript',
        'typescriptreact',
        -- 'typescript.tsx',
    },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    handlers = {
        -- handle rename request for certain code actions like extracting functions / types
        ['_typescript.rename'] = function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            vim.lsp.util.show_document({
                uri = result.textDocument.uri,
                range = {
                    start = result.position,
                    ['end'] = result.position,
                },
            }, client.offset_encoding)
            vim.lsp.buf.rename()
            return vim.NIL
        end,
    },
    commands = {
        ['editor.action.showReferences'] = function(command, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            ---@diagnostic disable
            ---@type string, lsp.Position, lsp.Location
            local file_uri, position, references = unpack(command.arguments)

            local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
            vim.fn.setqflist({}, ' ', {
                title = command.title,
                items = quickfix_items,
                context = {
                    command = command,
                    bufnr = ctx.bufnr,
                },
            })

            vim.lsp.util.show_document({
                uri = file_uri,
                range = {
                    start = position,
                    ['end'] = position,
                },
            }, client.offset_encoding)

            vim.cmd('botright copen')
        end,
    },
    on_attach = function(client, bufnr)
        -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
        -- `vim.lsp.buf.code_action()` if specified in `context.only`.
        vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptSourceAction', function()
            local source_actions = vim.tbl_filter(function(action)
                return vim.startswith(action, "source.")
            end, client.server_capabilities.codeActionProvider.codeActionKinds)

            vim.lsp.buf.code_action({
                ---@diagnostic disable-next-line
                context = {
                    only = source_actions,
                },
            })
        end, {})
    end,
}


vim.lsp.config["json"] = {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    init_options = {
        provideFormatter = true,
    },
    root_markers = { '.git' },
}

vim.lsp.config["cssls"] = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    init_options = { provideFormatter = true }, -- needed to enable formatting capabilities
    root_markers = { 'package.json', '.git' },
    settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
    },
}

vim.lsp.enable("luals")
vim.lsp.enable("html")
vim.lsp.enable("typescript")
vim.lsp.enable("json")
vim.lsp.enable("cssls")

-------------------------------------------------------
--- Diagnostic
-------------------------------------------------------

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        }
    }
})


-------------------------------------------------------
--- Loremipsum
-------------------------------------------------------

vim.api.nvim_create_user_command("Lorem", function(opts)
    local lorem_words = {
        "Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "quisque", "faucibus", "ex",
        "sapien", "vitae", "pellentesque", "sem", "placerat", "in", "id", "cursus", "mi", "pretium", "tellus", "duis",
        "convallis", "tempus", "leo", "eu", "aenean", "sed", "diam", "urna", "tempor", "pulvinar", "vivamus", "fringilla",
        "lacus", "nec", "metus", "bibendum", "egestas", "iaculis", "massa", "nisl", "malesuada", "lacinia", "integer",
        "nunc", "posuere", "ut", "hendrerit", "semper", "vel", "class", "aptent", "taciti", "sociosqu", "ad", "litora",
        "torquent", "per", "conubia", "nostra", "inceptos", "himenaeos", "orci", "varius", "natoque", "penatibus", "et",
        "magnis", "dis", "parturient", "montes", "nascetur", "ridiculus", "mus", "donec", "rhoncus", "eros", "lobortis",
        "nulla", "molestie", "mattis", "scelerisque", "maximus", "eget", "fermentum", "odio", "phasellus", "non", "purus",
        "est", "efficitur", "laoreet", "mauris", "pharetra", "vestibulum", "fusce", "dictum", "risus", "blandit", "quis",
        "suspendisse", "aliquet", "nisi", "sodales", "consequat", "magna", "ante", "condimentum", "neque", "at", "luctus",
        "nibh", "finibus", "facilisis", "dapibus", "etiam", "interdum", "tortor", "ligula", "congue", "sollicitudin",
        "erat", "viverra", "ac", "tincidunt", "nam", "porta", "elementum", "a", "enim", "euismod", "quam", "justo",
        "lectus", "commodo", "augue", "arcu", "dignissim", "velit", "aliquam", "imperdiet", "mollis", "nullam",
        "volutpat", "porttitor", "ullamcorper", "rutrum", "gravida", "cras", "eleifend", "turpis", "fames", "primis",
        "vulputate", "ornare", "sagittis", "vehicula", "praesent", "dui", "felis", "venenatis", "ultrices", "proin",
        "libero", "feugiat", "tristique", "accumsan", "maecenas", "potenti", "ultricies", "habitant", "morbi", "senectus",
        "netus", "suscipit", "auctor", "curabitur", "facilisi", "cubilia", "curae", "hac", "habitasse", "platea",
        "dictumst", "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "quisque", "faucibus",
        "ex", "sapien", "vitae", "pellentesque"
    }

    local n = tonumber(opts.args) or 20 -- default: 20 words if no param
    local result = {}

    for i = 1, n do
        table.insert(result, lorem_words[((i - 1) % #lorem_words) + 1])
    end

    local text = table.concat(result, " ")
    -- Capitalize the first word
    text = text:gsub("^%l", string.upper) .. "."

    vim.api.nvim_put({ text }, "c", true, true)
end, {
    nargs = "?",       -- optional argument
    complete = "file", -- makes command-line completion happy
})


-------------------------------------------------------
--- Create an autocmd group for quickfix settings
-------------------------------------------------------
vim.api.nvim_create_augroup("QuickfixSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = "QuickfixSettings",
    pattern = "qf",
    callback = function()
        vim.opt_local.wrap = false
    end,
})


-------------------------------------------------------
--- Display only errors in quick fix
-------------------------------------------------------

function ShowOnlyErrors()
    local qflist = vim.fn.getqflist()
    local errors = {}
    local any = false

    for _, item in ipairs(qflist) do
        if item.type == "E" then
            table.insert(errors, item)
            any = true
        end
    end

    if any then
        vim.fn.setqflist({}, 'r', { items = errors })
        vim.cmd("copen")
    end
end

map('n', "<leader>de", ":lua ShowOnlyErrors()<CR>", "Show only error items in quickfix.")

-------------------------------------------------------
--- Markdown settings
-------------------------------------------------------
local markdown = require("markdown")

map("n", '<leader>ml', markdown.insert_markdown_link, "Create new markdown link.")


-------------------------------------------------------
--- Git mode
-------------------------------------------------------
local git = require("git")

map("n", '<leader>mg', git.enable_git_mode, "Enable git mode.")
