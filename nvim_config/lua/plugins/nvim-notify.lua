return {
    'rcarriga/nvim-notify',
    config = function()
        require("notify").setup({
            merge_duplicates = false,
            render = "minimal",
            top_down = false,
            timeout = 2000
        })




        vim.notify = function(user_config, inherit, global_config)
            if global_config and global_config.replace == 'vim-dadbod-ui-info' then
                -- This is a workaround for the vim-dadbod-ui-info plugin.
                global_config.replace = nil
            end

            return require("notify")(user_config, inherit, global_config)
        end
    end
}
