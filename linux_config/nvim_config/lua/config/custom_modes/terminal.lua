local group = vim.api.nvim_create_augroup("terminal_mode", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function()

        vim.cmd("startinsert")

    end
})
