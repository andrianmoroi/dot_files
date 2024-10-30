function g() {
    local options=$(cat ~/.config/bookmarks.txt | awk 'NF { print $1;}')

    local selected=$(printf "%s\n" "${options[@]}" | fzf)

    local path=$(cat ~/.config/bookmarks.txt | grep "^\s*$selected" | awk '{ print $2; }')

    cd $path
}

function e() {
    g

    explorer.exe .

    cd - >> /dev/null
}


bind -x '"\C-g": g'  # Binds Ctrl+g to `my_function`

