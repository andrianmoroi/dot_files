function Get-BookmarkPath
{
    param (
        [string]$bookmark
    )

    if (Test-Path $BOOKMARKS_FILE)
    {
        $line = Select-String -Path $BOOKMARKS_FILE -Pattern "^$bookmark\s" | Select-Object -First 1

        if ($line)
        {
            $fields = $line.Line -split '\s+', 2

            return $fields[1]
        }
    }

    return $null
}

function g
{
    param(
        [string]$bookmark
    )

    $path = Get-BookmarkPath $bookmark

    if ($path -and (Test-Path $path))
    {
        Set-Location $path
    } else {
        Write-Error "Bookmark '$bookmark' not found or path does not exist."
    }
}

function o
{
    param(
        [string]$bookmark
    )

    g $bookmark
    n
}

Register-ArgumentCompleter -CommandName g -ParameterName bookmark -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    if (Test-Path $BOOKMARKS_FILE)
    {
        $bookmarks = Get-Content $BOOKMARKS_FILE | ForEach-Object {
            ($_ -split '\s+')[0]
        }

        $matches_bookmarks = $bookmarks | Where-Object { $_ -and $_ -like "$wordToComplete*" }

        $matches_bookmarks | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

Register-ArgumentCompleter -CommandName o -ParameterName bookmark -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    if (Test-Path $BOOKMARKS_FILE)
    {
        $bookmarks = Get-Content $BOOKMARKS_FILE | ForEach-Object {
            ($_ -split '\s+')[0]
        }

        $matches_bookmarks = $bookmarks | Where-Object { $_ -and $_ -like "$wordToComplete*" }

        $matches_bookmarks | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

