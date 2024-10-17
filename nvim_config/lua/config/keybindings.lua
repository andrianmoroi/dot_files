vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>h", ":Telescope help_tags<CR>", { desc = "Open [H]elp tags" })

-- Move through quick list
-- vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>")
-- vim.keymap.set("n", "<C-k>", "<cmd>cprevious<CR>")

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Insert tab character
vim.keymap.set("i", "<S-Tab>", "<C-V><Tab>")

-- TODO: improve this usecase, maybe use a TMUX split in the future.
vim.keymap.set("n", "<C-b>", ":horizontal terminal ./build.sh<CR>:resize 10<CR>")
