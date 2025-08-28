$BOOKMARKS_FILE = "$HOME\bookmarks.txt"
$PROJECTS_FILE = "$HOME\dotnet_projects.txt"

function prompt ()
{
    $p = Split-Path -Path (Get-Location) -Leaf
    $b = git branch --show-current

    $ESC = [char]27
    $directory_color = "$ESC[34m"
    $branch_color = "$ESC[33m"
    $clear_color = "$ESC[0m"

    "$directory_color$p $branch_color$b $clear_color"
}

function git_status()
{
    git status
}

function git_log()
{
    git log -20 --oneline --graph
}

# Set-Alias l ls
Set-Alias n nvim
Set-Alias gs git_status
Set-Alias gll git_log

# Set tab completion to show all options instead of cycle through them
Set-PSReadLineOption -CompletionQueryItems 1000
Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

function l
{
    param([string]$path = "")

    if ("" -eq $path)
    {
        $path = Get-Location
    } else
    {
        $path = Resolve-Path $path
    }

    $items = Get-ChildItem -Path $path

    # Print header
    Write-Host "`t$($path)"
    Write-Host ("{0,-15} {1,20} {2,10} {3}" -f "Mode", "LastWriteTime", "Length", "Name") -ForegroundColor Green
    Write-Host ("{0,-15} {1,20} {2,10} {3}" -f "----", "-------------", "------", "----") -ForegroundColor Green

    foreach ($item in $items)
    {
        $mode = $item.Mode
        $time = $item.LastWriteTime
        $length = if ($item.PSIsContainer) { "" } else { $item.Length }
        $name = $item.Name

        if ($item.PSIsContainer)
        {
            # Color folders cyan
            $name = "`e[34m$name`e[0m"  # ANSI cyan
        }

        "{0,-15} {1,-20} {2,10} {3}" -f $mode, $time, (DisplayWithBytes $length), $name
    }
}

function DisplayWithBytes ($num) {

    if($num -ne ""){

        switch ($num) {
            {$_ -lt 1KB} {$t=$_;$f=' B';break}
            {$_ -lt 1MB -and $_ -ge 1KB} {$t=$_/1KB;$f='KB';break}
            {$_ -lt 1GB -and $_ -ge 1MB} {$t=$_/1MB;$f='MB';break}
            {$_ -lt 1TB -and $_ -ge 1GB} {$t=$_/1GB;$f='GB';break}
        }

        ("{0:N1} {1}" -f $t, $f)
    }
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
    Import-Module "$ChocolateyProfile"
}



# Function to get the path from the bookmark name
function Get-BookmarkPath
{
    param (
        [string]$bookmark
    )
    if (Test-Path $BOOKMARKS_FILE)
    {
        # Find the line that starts with the bookmark followed by space, then get the second field
        $line = Select-String -Path $BOOKMARKS_FILE -Pattern "^$bookmark\s" | Select-Object -First 1
        if ($line)
        {
            $fields = $line -split '\s+'
            return $fields[1]
        }
    }
    return $null
}

# Tab completion function for 'g' and 'e'
function Complete-Bookmark
{
    param($wordToComplete, $commandAst, $cursorPosition)

    if (Test-Path $BOOKMARKS_FILE)
    {
        $bookmarks = Get-Content $BOOKMARKS_FILE | ForEach-Object {
            ($_ -split '\s+')[0]
        }

        $matches_bookmarks = $bookmarks | Where-Object { $_ -like "$wordToComplete*" }

        $matches_bookmarks | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# Go function: cd to the bookmarked folder
function g
{
    param(
        [string]$bookmark
    )
    $path = Get-BookmarkPath $bookmark
    if ($path -and (Test-Path $path))
    {
        Set-Location $path
    } else
    {
        Write-Error "Bookmark '$bookmark' not found or path does not exist."
    }
}

# Explorer function: open bookmarked folder in File Explorer
function e
{
    param(
        [string]$bookmark
    )
    $path = Get-BookmarkPath $bookmark
    if ($path -and (Test-Path $path))
    {
        Start-Process explorer.exe $path
    } else
    {
        Write-Error "Bookmark '$bookmark' not found or path does not exist."
    }
}

# Register tab completion for functions g and e
Register-ArgumentCompleter -CommandName g -ParameterName bookmark -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Complete-Bookmark $wordToComplete $commandAst $null
}

Register-ArgumentCompleter -CommandName e -ParameterName bookmark -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Complete-Bookmark $wordToComplete $commandAst $null
}



# Define the path to the dotnet projects file

# Function to get the path from the bookmark name
function Get-ProjectPath
{
    param (
        [string]$bookmark
    )

    if (Test-Path $PROJECTS_FILE)
    {
        $line = Select-String -Path $PROJECTS_FILE -Pattern "^$bookmark\s" | Select-Object -First 1

        if ($line)
        {
            $fields = $line -split '\s+'
            return $fields[1]
        }
    }

    return $null
}

# Tab completion function for 'g' and 'e'
function Complete-Project
{
    param($wordToComplete, $commandAst, $cursorPosition)

    if (Test-Path $PROJECTS_FILE)
    {
        $bookmarks = Get-Content $PROJECTS_FILE | ForEach-Object {
            ($_ -split '\s+')[0]
        }

        $matches_bookmarks = $bookmarks | Where-Object { $_ -like "$wordToComplete*" }

        $matches_bookmarks | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

function dr
{
    param(
        [string]$bookmark
    )

    $path = Get-ProjectPath $bookmark

    if ($path -and (Test-Path $path))
    {
        dotnet run --project $path
    } else
    {
        Write-Error "Project '$bookmark' not found or path does not exist."
    }
}

function dw
{
    param(
        [string]$bookmark
    )

    $path = Get-ProjectPath $bookmark

    if ($path -and (Test-Path $path))
    {
        dotnet watch --project $path
    } else
    {
        Write-Error "Project '$bookmark' not found or path does not exist."
    }
}

Register-ArgumentCompleter -CommandName dr -ParameterName bookmark -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Complete-Project $wordToComplete $commandAst $null
}

Register-ArgumentCompleter -CommandName dw -ParameterName bookmark -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Complete-Project $wordToComplete $commandAst $null
}


function Watch-AndTee {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$File,

        [string]$Trigger,

        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )

    begin {
        $oldEncoding = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $OutputEncoding = [System.Text.Encoding]::UTF8

        Clear-Content -Path $File -ErrorAction SilentlyContinue
    }


    process {
        $line = $InputObject

        if ($Trigger -and ($line -like $Trigger)) {
            Clear-Content -Path $File -ErrorAction SilentlyContinue

            Write-Host $InputObject
        }
        else {
            Write-Host $InputObject

            Add-Content -Path $File -Value $line
        }
    }
    end {
        # Restore original encoding
        [Console]::OutputEncoding = $oldEncoding
        $OutputEncoding = $oldEncoding
    }
}



