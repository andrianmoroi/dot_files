local telescope_builtin = require("telescope.builtin")

--
-- Common (useful)
--
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
vim.keymap.set("n", "<leader>W", "<cmd>w<CR>")
vim.keymap.set("n", "<leader>q", "<cmd>bdelete<CR>")
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>")
vim.keymap.set("n", "<leader>j", "<cmd>bnext<CR>")
vim.keymap.set("n", "<leader>k", "<cmd>bprevious<CR>")

-- Insert tab character
vim.keymap.set("i", "<S-Tab>", "<C-V><Tab>")
-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set("n", "<leader>zz", ":ZenMode<CR>", { desc = "[Z]en Mode" })
-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>/", function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    telescope_builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
    }))
end, { desc = "[/] Fuzzily search in current buffer" })


--
-- Important views
--
vim.keymap.set("n", "<C-h>", ":Telescope help_tags<CR>", { desc = "Open help tags" })
vim.keymap.set("n", "<C-g>", ":Neogit kind=replace<CR>", { desc = "Git View" })
-- vim.keymap.set("n", "<C-a>", ":DBUIToggle<CR>", { desc = "Database View" })
vim.keymap.set("n", "<C-e>", "<cmd>:Neotree toggle=true right<CR>")
-- TODO: improve this usecase, maybe use a TMUX split in the future.
vim.keymap.set("n", "<C-b>", ":horizontal terminal ./build.sh<CR>:resize 10<CR>")
vim.keymap.set(
    "n",
    "<C-p>",
    ':lua require("telescope.builtin").find_files({ hidden = true, file_ignore_patterns = { ".git"} })<CR>',
    { desc = "Search Files" }
)
vim.keymap.set("n", "<C-t>", ":UndotreeToggle<CR>:UndotreeFocus<CR>", { desc = "Toggle Undotree" })







-- vim.keymap.set("n", "<C-k>", ":Telescope keymaps<CR>")
-- vim.keymap.set("n", "<leader>n", ":bnext<CR>")

--
-- Quick list
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
-- vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>")
-- vim.keymap.set("n", "<C-k>", "<cmd>cprevious<CR>")



































vim.keymap.set("n", "<leader>sh", telescope_builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", telescope_builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>ss", telescope_builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", telescope_builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", telescope_builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", telescope_builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", telescope_builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", telescope_builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", telescope_builtin.buffers, { desc = "[ ] Find existing buffers" })


-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>s/", function()
    telescope_builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
    })
end, { desc = "[S]earch [/] in Open Files" })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set("n", "<leader>sn", function()
    telescope_builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
