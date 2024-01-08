parse_git_branch() {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

PS1=$'\\e[1;34m\\W\\e[1;33m$(parse_git_branch)\\e[40m\\e[0;37m ⮞ '
PS1='\[\033[1;34m\]\W\[\033[0m\]\[\033[1;33m\]$(parse_git_branch)\[\033[0m\] \[\033[1;36m\]$\[\033[0m\] '
