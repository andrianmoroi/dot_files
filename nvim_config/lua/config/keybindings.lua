local telescope_builtin = require("telescope.builtin")

--
-- Common (useful)
--
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })


local get_listed_bufs = function()
    return vim.tbl_filter(function(bufnr)
        return vim.api.nvim_buf_get_option(bufnr, "buflisted")
    end, vim.api.nvim_list_bufs())
end

local get_table_length = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end


vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Write file" })
-- vim.keymap.set("n", "<leader>q", ":bn|bd #<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>q", function()
    local bufs = get_listed_bufs()
    local count = get_table_length(bufs)

    if count == 0 then
        return
    end

    local buffer_index = vim.fn.bufnr()

    if count == 1 then
        vim.cmd(":Alpha")
    else
        vim.cmd(":bn")
    end

    vim.api.nvim_buf_delete(buffer_index, {})
end, { desc = "Close buffer" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>")

vim.keymap.set("n", "<C-n>", "<cmd>enew<CR>")
vim.keymap.set("n", "<C-w>n", "<cmd>vnew<CR>")


-- Insert tab character
vim.keymap.set("i", "<S-Tab>", "<C-V><Tab>")
vim.keymap.set("n", "<leader>/", function()
    telescope_builtin.current_buffer_fuzzy_find(
        require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
        }))
end, { desc = "Fuzzily search in current buffer" })

-- vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')
-- vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Zen Mode" })
vim.keymap.set("n",
    "<leader>x",
    [[:lua if vim.fn.expand('%:e') == 'sh' then vim.cmd('!chmod +x %') end <CR>]],
    { desc = "Make file Executable", noremap = true, silent = true })


--
-- Insert mode
--
--
-- vim.keymap.set("i", "\"", "\"\"<left>")
-- vim.keymap.set("i", "'", "''<left>")
-- vim.keymap.set("i", "(", "()<left>")
-- vim.keymap.set("i", "{", "{}<left>")
-- vim.keymap.set("i", "[", "[]<left>")

--
-- Visual mode
--
vim.keymap.set("v", "<C-s>", ":sort<CR>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

--
-- Important Control views
--

vim.keymap.set("n", "<C-e>", "<cmd>:Neotree toggle=true right<CR>")
vim.keymap.set("n", "<S-e>", "<cmd>:Telescope file_browser<CR>")
vim.keymap.set("n", "<C-l>", "<cmd>:Lazy update<CR>")
vim.keymap.set("n", "<C-h>", ":Telescope help_tags<CR>", { desc = "Open help tags" })
vim.keymap.set("n", "<C-g>", ":Neogit kind=replace<CR>", { desc = "Git View" })
vim.keymap.set("n", "<C-b>", ":horizontal terminal ./build.sh<CR>:resize 10<CR>")
vim.keymap.set("n", "<C-B>", ":vertical terminal ./build.sh<CR>")
vim.keymap.set("n", "<leader>z", ":%s/\\v", { desc = "[R]eplace"})
vim.keymap.set({ 'n', 'v' }, '<leader>a', ':Gen<CR>', { desc = "[A]ssistant"})

-- TODO: improve this usecase, maybe use a TMUX split in the future.
vim.keymap.set(
    "n",
    "<C-p>",
    ':lua require("telescope.builtin").find_files({ find_command={"find", ".", "-type", "f", "-not", "-path", "./.git/*", "-printf", "%P\\n"}})<CR>',
    { desc = "Search Files" }
)


--
-- Resize panes
--
vim.keymap.set("n", "<C-w>+", "5<C-w>+")
vim.keymap.set("n", "<C-w>-", "5<C-w>-")
vim.keymap.set("n", "<C-w>>", "5<C-w>>")
vim.keymap.set("n", "<C-w><", "5<C-w><")


--
-- Views
--
vim.keymap.set("n", "<leader>vu", ":UndotreeToggle<CR>:UndotreeFocus<CR>", { desc = "[U]ndotree" })
vim.keymap.set("n", "<leader>vd", ":DBUIToggle<CR>", { desc = "[D]atabase" })


vim.keymap.set("n", "<leader>sh", telescope_builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", telescope_builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sw", telescope_builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", telescope_builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sr", telescope_builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", telescope_builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", telescope_builtin.buffers, { desc = "Find existing buffers" })
vim.keymap.set("n", "<leader>sn", function()
    telescope_builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })






-- Quick list
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
-- vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>")
-- vim.keymap.set("n", "<C-k>", "<cmd>cprevious<CR>")

-- Need to move
vim.keymap.set("n", "<leader>sd", telescope_builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
