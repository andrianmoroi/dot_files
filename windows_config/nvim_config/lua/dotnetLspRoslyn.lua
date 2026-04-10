local uv = vim.uv
local fs = vim.fs

-------------------------------------------------------
--- Load roslyn.nvim package
-------------------------------------------------------

vim.pack.add({
    "https://github.com/seblyng/roslyn.nvim",
}, { load = true })

require("roslyn").setup({
    silent = true,
    filewatching = "roslyn"
})

-------------------------------------------------------
--- Setup Roslyn
-------------------------------------------------------

---@param client vim.lsp.Client
---@param target string
local function on_init_sln(client, target)
    vim.notify('Initializing: ' .. target, vim.log.levels.TRACE, { title = 'roslyn_ls' })
    ---@diagnostic disable-next-line: param-type-mismatch
    client:notify('solution/open', {
        solution = vim.uri_from_fname(target),
    })
end

---@param client vim.lsp.Client
---@param project_files string[]
local function on_init_project(client, project_files)
    vim.notify('Initializing: projects', vim.log.levels.TRACE, { title = 'roslyn_ls' })
    ---@diagnostic disable-next-line: param-type-mismatch
    client:notify('project/open', {
        projects = vim.tbl_map(function(file)
            return vim.uri_from_fname(file)
        end, project_files),
    })
end

local function roslyn_handlers()
    local result = {
        ['workspace/projectInitializationComplete'] = function(_, _, ctx)
            vim.notify('Roslyn project initialization complete', vim.log.levels.INFO, { title = 'roslyn_ls' })

            local buffers = vim.lsp.get_client_by_id(ctx.client_id).attached_buffers
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            for buf, is_attached in pairs(buffers) do
                if is_attached then
                    client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, {
                        textDocument = vim.lsp.util.make_text_document_params(buf),
                    }, nil, buf)
                end
            end
        end,
        ['workspace/_roslyn_projectHasUnresolvedDependencies'] = function()
            vim.notify('Detected missing dependencies. Run `dotnet restore` command.', vim.log.levels.ERROR, {
                title = 'roslyn_ls',
            })
            return vim.NIL
        end,
        ['workspace/_roslyn_projectNeedsRestore'] = function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            ---@diagnostic disable-next-line: param-type-mismatch
            client:request('workspace/_roslyn_restore', result, function(err, response)
                if err then
                    vim.notify(err.message, vim.log.levels.ERROR, { title = 'roslyn_ls' })
                end
                if response then
                    for _, v in ipairs(response) do
                        vim.notify(v.message, vim.log.levels.INFO, { title = 'roslyn_ls' })
                    end
                end
            end)

            return vim.NIL
        end,
    }

    return result
end

local code_analisys_path = vim.fs.joinpath(
    os.getenv("MicrosoftCodeAnalysisLanguageServer"),
    'Microsoft.CodeAnalysis.LanguageServer.dll')


-- To install run:
-- Go to
-- https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl/NuGet/Microsoft.CodeAnalysis.LanguageServer.<platform>/overview
-- replace <platform> with one of the following linux-x64, osx-x64, win-x64, neutral.
-- Download and extract it (nuget's are zip files).

---@type vim.lsp.Config
vim.lsp.config['roslyn'] = {
    name = 'roslyn_ls',
    offset_encoding = 'utf-8',
    cmd = {
        'dotnet',
        code_analisys_path,
        '--logLevel=Warning',
        '--stdio',
        '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.log.get_filename()),
    },
    filetypes = { 'cs' },
    handlers = roslyn_handlers(),
    root_dir = function(bufnr, cb)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        -- don't try to find sln or csproj for files from libraries
        -- outside of the project
        if not bufname:match('^' .. fs.joinpath('/tmp/MetadataAsSource/')) then
            -- try find solutions root first
            local root_dir = fs.root(bufnr, function(fname, _)
                return fname:match('%.sln[x]?$') ~= nil
            end)

            if not root_dir then
                -- try find projects root
                root_dir = fs.root(bufnr, function(fname, _)
                    return fname:match('%.csproj$') ~= nil
                end)
            end

            if root_dir then
                cb(root_dir)
            end
        end
    end,
    on_init = {
        function(client)
            local root_dir = client.config.root_dir

            -- try load first solution we find
            for entry, type in fs.dir(root_dir) do
                if type == 'file' and (vim.endswith(entry, '.sln') or vim.endswith(entry, '.slnx')) then
                    on_init_sln(client, fs.joinpath(root_dir, entry))
                    return
                end
            end

            -- if no solution is found load project
            for entry, type in fs.dir(root_dir) do
                if type == 'file' and vim.endswith(entry, '.csproj') then
                    on_init_project(client, { fs.joinpath(root_dir, entry) })
                end
            end
        end,
    },
    capabilities = {
        -- HACK: Doesn't show any diagnostics if we do not set this to true
        textDocument = {
            diagnostic = {
                dynamicRegistration = true,
            },
        },
    },
    settings = {
        ['csharp|background_analysis'] = {
            dotnet_analyzer_diagnostics_scope = 'fullSolution',
            dotnet_compiler_diagnostics_scope = 'fullSolution',
        },
        ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
        },
        ['csharp|completion'] = {
            dotnet_show_name_completion_suggestions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_provide_regex_completions = true,
        },
        ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },
        ['csharp|symbol_search'] = {
            dotnet_search_reference_assemblies = true,
        },
    },
}

vim.lsp.log.set_level(vim.log.levels.WARN)
vim.lsp.enable("roslyn")

--------------------------------------------------------------------------------
--- Dotnet load errors and warnings from watch to QuickFixList
--------------------------------------------------------------------------------

local function is_dir(path)
    local stat = uv.fs_stat(path)

    return stat and stat.type == "directory"
end

local function find_vs_folder(path)
    local vs_path = path .. "\\.vs"

    if is_dir(vs_path) then
        return vs_path
    end

    local parent = path:match("^(.*)/[^/]+$")
    if not parent or parent == path then
        return nil
    end

    return find_vs_folder(parent)
end

local function load_erros_and_warnings_to_qfl(logfile)
    local quickfix_items = {}

    vim.fn.setqflist({}, 'r')

    for line in io.lines(logfile) do
        -- 1. Remove ANSI color codes
        line = line:gsub("\27%[[%d;]*[A-Za-z]", "")
    end

    -- 2. Normalize Windows paths to forward slashes
    vim.fn.setqflist({}, 'r')

    for line in io.lines(logfile) do
        -- 1. Remove ANSI color codes
        line = line:gsub("\27%[[%d;]*[A-Za-z]", "")

        -- 2. Normalize Windows paths to forward slashes
        line = line:gsub("\\", "/")

        -- 3. Match only lines you care about
        -- Example: errors, warnings, exceptions
        if line:match("error CS%d+") or line:match("warning CS%d+") or line:match("Exception") then
            -- Try to parse file/line/col/message
            local file, lnum, col, type, msg = line:match(
                "([%w%p]+%.%w+)"    -- file path
                .. "%s*[%(:]?%s*"   -- optional '(' or ':' after file
                .. "(%d*)"          -- optional line number
                .. ",?(%d*)[%)]?"   -- optional column number, optional ')'
                .. "[:]?%s*"        -- optional ':' after line/col
                .. "(%a+)%s*%w+[:]" -- type: warning / error
                .. "(.*)%[?%w*%]?$" -- message
            )

            lnum = tonumber(lnum) or 0
            col = tonumber(col) or 0
            msg = msg or line

            local qf_type = nil
            if type == nil then

            elseif type:lower():match("^error") then
                qf_type = "E"
            elseif type:lower():match("^warn") then
                qf_type = "W"
            else
                qf_type = "I" -- info or unknown
            end

            table.insert(quickfix_items, {
                filename = file or "",
                lnum = lnum,
                col = col,
                text = msg:gsub("^%s+", ""):gsub("%s+$", ""),
                type = qf_type
            })
        end
    end

    local function distinct_quickfix(items)
        local seen = {}
        local result = {}

        for _, item in ipairs(items) do
            -- Use a combination of filename, line, column, text, and type as the key
            local key = string.format("%s|%d|%d|%s|%s",
                item.filename or "",
                item.lnum or 0,
                item.col or 0,
                item.text or "",
                item.type or ""
            )

            if not seen[key] then
                table.insert(result, item)
                seen[key] = true
            end
        end

        return result
    end

    -- Populate Neovim quickfix
    vim.fn.setqflist({}, ' ', { title = 'Dotnet Watch', items = distinct_quickfix(quickfix_items) })
    vim.cmd("copen")
end


vim.api.nvim_create_user_command("DotnetLoadErrors", function()
    local current_path = vim.fn.getcwd()
    local vs_path = find_vs_folder(current_path)

    if vs_path then
        local log_file_name = "dotnet_log_file.txt" -- vim.fn.getenv("DOTNET_LOG_FILE_NAME")
        local log_file = vs_path .. "\\" .. log_file_name

        load_erros_and_warnings_to_qfl(log_file)
    else
        vim.api.nvim_echo({ { "VS folder not found." } }, true, {})
    end
end, {})


vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if client and (client.name == "roslyn" or client.name == "roslyn_ls") then
            vim.api.nvim_create_autocmd("InsertCharPre", {
                desc = "Roslyn: Trigger an auto insert on '/'.",
                buffer = bufnr,
                callback = function()
                    local char = vim.v.char

                    if char ~= "/" then
                        return
                    end

                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    row, col = row - 1, col + 1
                    local uri = vim.uri_from_bufnr(bufnr)

                    local params = {
                        _vs_textDocument = { uri = uri },
                        _vs_position = { line = row, character = col },
                        _vs_ch = char,
                        _vs_options = {
                            tabSize = vim.bo[bufnr].tabstop,
                            insertSpaces = vim.bo[bufnr].expandtab,
                        },
                    }

                    -- NOTE: We should send textDocument/_vs_onAutoInsert request only after
                    -- buffer has changed.
                    vim.defer_fn(function()
                        client:request(
                        ---@diagnostic disable-next-line: param-type-mismatch
                            "textDocument/_vs_onAutoInsert",
                            params,
                            function(err, result, _)
                                if err or not result then
                                    return
                                end

                                vim.snippet.expand(result._vs_textEdit.newText)
                            end,
                            bufnr
                        )
                    end, 1)
                end,
            })
        end
    end,
})
