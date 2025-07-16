function new_todo() {
    file_path=${TODO_PATH:-~/.config/notes/todo.md}
    dir_path=$(dirname $file_path)

    mkdir -p $dir_path
    touch -a $file_path

    nvim $file_path -n
}
