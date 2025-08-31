local uv = vim.uv
local fs = vim.fs

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

            local buffers = vim.lsp.get_buffers_by_client_id(ctx.client_id)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            for _, buf in ipairs(buffers) do
                client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, {
                    textDocument = vim.lsp.util.make_text_document_params(buf),
                }, nil, buf)
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

local code_analisys_path = vim.fs.joinpath(os.getenv("MicrosoftCodeAnalysisLanguageServer"),
    'Microsoft.CodeAnalysis.LanguageServer.dll')

---@type vim.lsp.Config
vim.lsp.config['roslyn'] = {
    name = 'roslyn_ls',
    offset_encoding = 'utf-8',
    cmd = {
        'dotnet',
        code_analisys_path,
        '--logLevel=Information',
        '--stdio',
        '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
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
            vim.print(root_dir)

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
        ['csharp|completion'] = {
            dotnet_show_name_completion_suggestions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_provide_regex_completions = true,
        },
        ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
        },
    },
}


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
            local file, lnum, col, msg = line:match("([%w%p]+%.%w+)%((%d+),?(%d*)%)[:]?%s*(.*)")
            lnum = tonumber(lnum) or 0
            col = tonumber(col) or 0
            msg = msg or line

            table.insert(quickfix_items, {
                filename = file or "",
                lnum = lnum,
                col = col,
                text = msg
            })
        end
    end

    -- Populate Neovim quickfix
    vim.fn.setqflist({}, ' ', { title = 'Dotnet Watch', items = quickfix_items })
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
        vim.api.nvim_err_writeln("VS folder not found.")
    end
end, {})

