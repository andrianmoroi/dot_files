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
