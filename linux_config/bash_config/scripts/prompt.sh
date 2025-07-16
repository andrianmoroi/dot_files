function _parse_git_branch() {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

# ⛔ -- 26d4
# ❌ -- 274c
function _exit_code() {
    if [ $? != 0 ]; then
        echo "❌ "
    fi
}

PS1=$'\\e[1;34m\\W\\e[1;33m$(_parse_git_branch)\\e[40m\\e[0;37m ⮞ '
PS1='$(_exit_code)\[\033[1;34m\]\W\[\033[0m\]\[\033[1;33m\]$(_parse_git_branch)\[\033[0m\] \[\033[1;36m\]$\[\033[0m\] '

export FZF_DEFAULT_OPTS='--layout=reverse --height=10%'
