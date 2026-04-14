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

-- vim.opt.foldopen = "all"

vim.keymap.set('n', "<M-j>", "zj", { desc = "Next fold." })
vim.keymap.set('n', "<M-k>", "zk", { desc = "Previous fold." })

vim.g.fold_enable = true

vim.keymap.set("n", "<leader>zi", function()
    vim.g.fold_enable = not vim.g.fold_enable

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.api.nvim_set_option_value("foldenable", vim.g.fold_enable, { scope = "local", win = win })
    end

end, { desc = "Toggle fold enable." })
