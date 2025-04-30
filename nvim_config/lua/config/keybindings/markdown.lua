vim.keymap.set("n", "<leader>mc", "<cmd>.s/- \\[ \\]/- \\[x\\]/<CR>", { desc = "[C]heck" })
vim.keymap.set("n", "<leader>mu", "<cmd>.s/- \\[x\\]/- \\[ \\]/<CR>", { desc = "[U]ncheck" })


local function toggle_markdown_task()
    local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(0, line_nr, line_nr + 1, false)[1]

    local trimmed = line:match("^%s*(.-)$")
    local new_line

    if trimmed:match("^%- %[ %]") then
        new_line = line:gsub("%- %[% %]", "- [-]", 1)
    elseif trimmed:match("^%- %[%-%]") then
        new_line = line:gsub("%- %[%-%]", "- [x]", 1)
    elseif trimmed:match("^%- %[x%]") then
        new_line = line:gsub("%- %[x%]", "- [ ]", 1)
    else
        new_line = "- [ ] " .. line
    end




    vim.api.nvim_buf_set_lines(0, line_nr, line_nr + 1, false, { new_line })

    vim.print(new_line)
end

vim.keymap.set("n", "<leader>mt", function() toggle_markdown_task() end, { desc = "[T]oggle task" })
