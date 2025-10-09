
function git_status()
{
    git status
}

function git_log()
{
    git log -20 --oneline --graph
}

Set-Alias n nvim
Set-Alias f firefox.exe
Set-Alias gs git_status
Set-Alias gll git_log

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
