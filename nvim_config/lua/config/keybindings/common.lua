vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>x", "<cmd>luafile %<CR>", { desc = "Execute luafile" })

vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Write file" })
vim.keymap.set("n", "<leader>cs", function()
    local spell = vim.api.nvim_get_option_value("spell", {})

    vim.api.nvim_set_option_value("spell", not spell, {})
end, { desc = "Toggle spell checking" })

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

    vim.api.nvim_buf_delete(buffer_index, { force = true })
end, { desc = "Close buffer" })

vim.keymap.set("n", "<M-q>", ":q<CR>", { desc = "Close pane" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Switch to previous buffer" })

vim.keymap.set("n", "<C-n>", "<cmd>enew<CR>", { desc = "New empty buffer" })
vim.keymap.set("n", "<C-w>n", "<cmd>vnew<CR>", { desc = "New vertical empty buffer" })

-- Insert tab character
vim.keymap.set("i", "<S-Tab>", "<C-V><Tab>", { desc = "Insert tab character" })

vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>cprevious<CR>")

vim.keymap.set("n", "<C-w>+", "7<C-w>+")
vim.keymap.set("n", "<C-w>-", "7<C-w>-")
vim.keymap.set("n", "<C-w>>", "7<C-w>>")
vim.keymap.set("n", "<C-w><", "7<C-w><")

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { desc = "Paste from clipboard" })

-- vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')
