function get_pwd() {
  echo "${PWD/$HOME/~}"
}

PROMPT='%D{%H:%M:%S} $fg[cyan]%m:$fg[yellow]$(get_pwd)$reset_color $fg[magenta]$(virtualenv_prompt_info)$reset_color$(git_super_status)%(!.#.$)
'
