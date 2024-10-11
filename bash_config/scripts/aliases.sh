alias n="nvim"
alias gs="git status"
alias gc="git add . && git commit -m"
alias gl="git log --oneline"

# alias l='lsd --group-dirs first -lAhF'
alias l='ls --color --group-directories-first -lAhF'
alias b="cat ~/.config/bookmarks.txt | awk '{print \$1}' | grep .| fzf --preview \"cat ~/.config/bookmarks.txt | grep '^{}' | sed 's|^[^ \t]*\s*||' | xargs tree -L 1 | head -n 20\""

alias sync-configs="cd ~/.config/.dot_files/bash_config && git pull origin main && ./install.sh && cd - >> /dev/null"
