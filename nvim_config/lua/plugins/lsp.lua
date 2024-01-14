return {
    { "williamboman/mason.nvim" },
    { "neovim/nvim-lspconfig" },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config=function()
            require("mason").setup({
            })
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "tsserver" }
            })
            require("lspconfig").lua_ls.setup({})
            require("lspconfig").tsserver.setup({})
        end
    },
}
