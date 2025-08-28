$BOOKMARKS_FILE = "$HOME\bookmarks.txt"
$PROJECTS_FILE = "$HOME\dotnet_projects.txt"
$DOTNET_LOG_FILE_NAME = "dotnet_log_file.txt"

# Set tab completion to show all options instead of cycle through them
Set-PSReadLineOption -CompletionQueryItems 1000
Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

. "$PSScriptRoot\powershell_config\aliases.ps1"
. "$PSScriptRoot\powershell_config\bookmarks.ps1"
. "$PSScriptRoot\powershell_config\dotnet.ps1"
. "$PSScriptRoot\powershell_config\prompt.ps1"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
