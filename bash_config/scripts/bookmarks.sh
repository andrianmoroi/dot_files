BOOKMARKS_FILE=~/.config/bookmarks.txt

function _g_path() {
    echo $(grep "^$1\s" $BOOKMARKS_FILE | awk -F ' ' '{print $2}')
}

function _g_options() {

    if [ -f "$BOOKMARKS_FILE" ] && [ "${#COMP_WORDS[@]}" == "2" ]; then
        local all_options=$(awk -F ' ' '{print $1}' $BOOKMARKS_FILE)
        local show_options=$(compgen -W "$all_options" -- "${COMP_WORDS[1]}")

        COMPREPLY=($show_options)
    else
        return
    fi
}

# # Go function - cd to a folder stored in bookmark
# function g() {
#     local path=`_g_path $1`
#
#     cd $path
# }

# Explorer function - open bookmark folder in windows explorer.
# function e() {
     local path=`_g_path $1`
#
#     cd $path
#     explorer.exe .
#     cd - >> /dev/null
# }

complete -F _g_options g
complete -F _g_options e
