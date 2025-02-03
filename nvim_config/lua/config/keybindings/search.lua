local telescope = require("telescope.builtin")

vim.keymap.set("n", "<leader>sh", telescope.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sb", telescope.buffers, { desc = "Find existing buffers" })
vim.keymap.set("n", "<leader>sg", telescope.live_grep, { desc = "[S]earch by [G]rep" })

vim.keymap.set("n", "<leader>sk", telescope.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sw", telescope.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sr", telescope.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", telescope.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })

vim.keymap.set("n", "<leader>s/", function()
    telescope.current_buffer_fuzzy_find(
        require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
        }))
end, { desc = "Fuzzily search in current buffer" })

vim.keymap.set(
    "n",
    "<leader>sc",
    function()
        telescope.find_files({ cwd = vim.fn.stdpath("config") })
    end,
    { desc = "[S]earch [N]eovim files" }
)




