-------------------------------------------------------
--- Shell option
-------------------------------------------------------

-- Use pwsh if available, otherwise fallback to powershell
vim.o.shell            = vim.fn.executable('pwsh') == 1 and 'pwsh' or 'powershell'

-- Set shell command flags
vim.o.shellcmdflag     = table.concat({
    '-NoLogo',
    '-NonInteractive',
    '-ExecutionPolicy RemoteSigned',
    '-Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();',
    "$PSDefaultParameterValues['Out-File:Encoding']='utf8';",
    "$PSStyle.OutputRendering='plaintext';",
    'Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
}, ' ')

-- Set shell redirection
vim.o.shellredir       = '2>&1 | %{{ "$_" }} | Out-File %s; exit $LastExitCode'
vim.o.shellpipe        = '2>&1 | %{{ "$_" }} | tee %s; exit $LastExitCode'

-- Disable shell quoting
vim.o.shellquote       = ''
vim.o.shellxquote      = ''

