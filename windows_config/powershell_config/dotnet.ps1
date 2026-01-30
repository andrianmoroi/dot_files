
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

        if ($Trigger -and ($line -match $Trigger)) {
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

function Find-VsFolderRecursive {
    param([string]$path)

    $vs = Join-Path $path ".vs"

    if (Test-Path $vs -PathType Container) {
        return $vs
    }

    $parent = (Get-Item $path).Parent

    if ($parent -eq $null) {
        return $null
    }

    return Find-VsFolderRecursive -path $parent.FullName
}

function Dotnet-Command {
    param(
        [string]$bookmark,
        [string]$command
    )

    $path = Get-ProjectPath $bookmark
    $vsPath = Find-VsFolderRecursive $path

    if ($path -and (Test-Path $path) -and $vsPath)
    {
        $logFile = Join-Path $vsPath $DOTNET_LOG_FILE_NAME

        dotnet $command --project $path | Watch-AndTee -File $logFile -Trigger "File updated:|Restart requested.|Building.*\.\.\."
    } else {
        Write-Error "Project '$bookmark' not found or path does not exist."
    }
}

function dr
{
    param(
        [string]$bookmark
    )

    Dotnet-Command $bookmark run
}

function dw
{
    param([string]$bookmark)

    $path = Get-ProjectPath $bookmark
    $vsPath = Find-VsFolderRecursive $path

    if ($path -and (Test-Path $path) -and $vsPath)
    {
        $logFile = Join-Path $vsPath $DOTNET_LOG_FILE_NAME

        dotnet watch run --project $path 2>&1 | Watch-AndTee -File $logFile -Trigger "File updated:|Restart requested.|Building.*\.\.\."
    } else {
        Write-Error "Project '$bookmark' not found or path does not exist."
    }
}

function Complete-Project
{
    param($wordToComplete, $commandAst, $cursorPosition)

    if (Test-Path $PROJECTS_FILE)
    {
        $bookmarks = Get-Content $PROJECTS_FILE | ForEach-Object {
            ($_ -split '\s+')[0]
        }

        $matches_bookmarks = $bookmarks | Where-Object { $_ -and $_ -like "$wordToComplete*" }

        $matches_bookmarks | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
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

