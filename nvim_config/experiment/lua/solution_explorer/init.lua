local M = {}

local common = require("common")
local tokenizer = require("sln_tokenizer")

function M.solution_explorer()
    local folderPath = "/mnt/c/Work/projects/OmicsReportEngine"
    local slnFiles = common.get_files_with_extension(folderPath, "sln")
    common.print_table(slnFiles)

    tokenizer.tokenize_file(slnFiles[1])

    -- vim.cmd("vsplit")
    --
    -- local buf = vim.api.nvim_create_buf(false, true)
    -- vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
    --
    -- vim.api.nvim_set_current_buf(buf)
    --
    -- vim.bo[buf].buftype = "nofile"
    -- vim.bo[buf].bufhidden = "wipe"
    -- vim.bo[buf].swapfile = false
    --
    --
    -- local path = folderPath -- vim.fn.expand("%:p:h")
    -- local files = vim.fn.readdir(path)
    --
    -- vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)
    --
    -- -- vim.api.nvim_buf_set_keymap(
    -- -- 	buf,
    -- -- 	"n",
    -- -- 	"<CR>",
    -- -- 	':lua require("myfileexplorer").open_file()<CR>',
    -- -- 	{ noremap = true, silent = true }
    -- -- )
    --
    -- vim.bo[buf].modifiable = false
end

function M.open_file()
    local line = vim.fn.getline(".")
    local filepath = vim.fn.expand("%:p:h") .. "/" .. line

    vim.cmd("edit " .. filepath)
end

vim.api.nvim_create_user_command("SolutionExplorer", M.solution_explorer, {})

vim.keymap.set("n", "<C-x>", function()
    package.loaded.common = nil
    package.loaded.sln_tokenizer = nil
    common = require("common")
    tokenizer = require("sln_tokenizer")
    vim.notify("Reloaded modules")
end)

vim.api.nvim_set_keymap("n", "<C-n>", ":SolutionExplorer<CR>", { noremap = true, silent = true })

return M
