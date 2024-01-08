local opts = { noremap = true, silent = true }

-- set custom buffers commands
vim.api.nvim_set_keymap("n", "<leader>w", ":w<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>W", ":w<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>c", ":bdelete<cr>", opts)

-- open explorer
vim.api.nvim_set_keymap("n", "<leader>e", ":Lexplore 20<cr>", opts)

-- open telescope
vim.api.nvim_set_keymap("n", "<leader>b", ":Telescope buffers<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>f", ":Telescope find_files<cr>", opts)
