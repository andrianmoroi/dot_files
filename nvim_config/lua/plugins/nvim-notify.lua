return {
    'rcarriga/nvim-notify',
    config = function()
        vim.notify = function(user_config, inherit, global_config)

            if global_config and global_config.replace == 'vim-dadbod-ui-info' then
                -- This is a workaround for the vim-dadbod-ui-info plugin.
                global_config.replace = nil
            end

            return require("notify")(user_config, inherit, global_config)
        end
    end
}
