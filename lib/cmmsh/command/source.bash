
command_entry() {
    local recipes=("${@}")
    cmmsh_core_include cmmsh/recipe
    cmmsh_recipe_source "${@}"
}
