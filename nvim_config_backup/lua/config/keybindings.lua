-- local telescope_builtin = require("telescope.builtin")

require("config.keybindings.common")
require("config.keybindings.markdown")
require("config.keybindings.search")







-- vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Zen Mode" })

vim.keymap.set("n",
    "<leader>cx",
    [[:lua if vim.fn.expand('%:e') == 'sh' then vim.cmd('!chmod +x %') end <CR>]],
    { desc = "Make file Executable", noremap = true, silent = true })

-- Visual mode
--
vim.keymap.set("v", "<C-s>", ":sort<CR>")
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

--
-- Important Control views
--

vim.keymap.set("n", "<C-e>", function() require("mini.files").open() end)

-- vim.keymap.set("n", "<S-e>", "<cmd>:Neotree toggle=true right<CR>")
-- vim.keymap.set("n", "<C-e>", "<cmd>:Telescope file_browser<CR>")
vim.keymap.set("n", "<C-l>", "<cmd>:Lazy update<CR>")
vim.keymap.set("n", "<C-h>", ":Telescope help_tags<CR>", { desc = "Open help tags" })
-- vim.keymap.set("n", "<C-g>", ":Neogit kind=replace<CR>", { desc = "Git View" })
vim.keymap.set("n", "<C-b>", ":horizontal terminal ./build.sh<CR>:resize 10<CR>")
-- vim.keymap.set("n", "<C-B>", ":vertical terminal ./build.sh<CR>")
vim.keymap.set("n", "<leader>z", ":%s/\\v", { desc = "[R]eplace" })
vim.keymap.set("x", "<leader>z", ":s/\\v", { desc = "[R]eplace" })
vim.keymap.set({ 'n', 'v' }, '<leader>a', ':Gen<CR>', { desc = "[A]ssistant" })

-- TODO: improve this usecase, maybe use a TMUX split in the future.
vim.keymap.set(
    "n",
    "<C-p>",
    ':lua require("telescope.builtin").find_files({ find_command={"find", ".", "-type", "f", "-not", "-path", "./.*/*", "-printf", "%P\\n"}})<CR>',
    { desc = "Search Files" }
)


--
-- Resize panes
--


--
-- Views
--
vim.keymap.set("n", "<leader>vu", ":UndotreeToggle<CR>:UndotreeFocus<CR>", { desc = "[U]ndotree" })
vim.keymap.set("n", "<leader>vd", ":DBUIToggle<CR>", { desc = "[D]atabase" })





-- Quick list
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Need to move
