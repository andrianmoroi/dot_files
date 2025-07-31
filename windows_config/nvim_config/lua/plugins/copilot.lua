return {
    {
        "github/copilot.vim",
        tag="v1.51.0",
        config = function()
            vim.api.nvim_create_autocmd('ColorScheme', {
                pattern = 'solarized',
                callback = function()
                    vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
                        fg = '#555555',
                        ctermfg = 8,
                        force = true
                    })
                end
            })



            vim.g.copilot_filetypes = {
                ["*"] = false,
                ["javascript"] = true,
                ["typescript"] = true,
                ["python"] = true,
                ["lua"] = true,
                ["chsarp"] = true,
            }
        end,
    }
}
