-------------------------------------------------------
--- Treesitter
-------------------------------------------------------

vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim", -- need for nvim-treesitter

    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main"
    }
}, { load = true })

require("nvim-treesitter")
    .install({ "c_sharp", "javascript", "typescript", "jsx", "tsx", "html", "css" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "cs", "javascript", "typescript", "json", "javascriptreact", "typescriptreact", "html"
    },
    callback = function()
        vim.treesitter.start()                               -- highlighting
        vim.opt.foldmethod = 'expr'
        vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- folds

        vim.wo.foldenable = vim.g.fold_enable
    end,
})


vim.treesitter.query.set("c_sharp", "folds", [[
    (method_declaration
      body: (block) @fold)

    (constructor_declaration
      body: (block) @fold)
]])

vim.treesitter.query.set("typescript", "folds", [[
    (type_alias_declaration
      value: (object_type) @fold)

    (function_declaration
      body: (statement_block) @fold)
]])

vim.treesitter.query.set("tsx", "folds", [[
    (function_declaration
      body: (statement_block) @fold)
]])

require("nvim-treesitter").update()
