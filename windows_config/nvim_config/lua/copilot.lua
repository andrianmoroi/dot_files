local BufferName = "[Copilot]"

local function find_buf_by_name(name)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local n = vim.api.nvim_buf_get_name(bufnr)

        if n == name or vim.fn.fnamemodify(n, ":t") == name then
            return bufnr
        end
    end

    return nil
end


vim.keymap.set("n", "<leader>cc", function()
    local copilot_buff = find_buf_by_name(BufferName)

    vim.cmd("vsplit")

    if copilot_buff == nil then
        vim.cmd(":terminal co --continue")

        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_name(buf, BufferName)

        vim.api.nvim_buf_set_keymap(buf, "t", "<M-q>", "<C-\\><C-n>:close<CR>", { desc = "Hide copilot."})
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-W><C-W>", "<C-\\><C-n><C-W><C-W>", { desc = "Move next window."})
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-W>o", "<C-\\><C-n><C-W>o:startinsert<CR>", { desc = "Maximize window."})

        vim.bo.buflisted = false

    else
        vim.api.nvim_set_current_buf(copilot_buff)
    end

    vim.cmd("startinsert")
end, { desc = "Open copilot" })
