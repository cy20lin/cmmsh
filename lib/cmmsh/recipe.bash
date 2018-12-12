if test ! -z "${CMMSH_RECIPE_BASH_INCLUDED}"
then
    return 1
fi
CMMSH_RECIPE_BASH_INCLUDED=1

cmmsh_core_include cmmsh/core
cmmsh_core_include cmmsh/algorithm
cmmsh_core_include cmmsh/map
cmmsh_core_include cmmsh/action

CMMSH_RECIPE_DIR="${CMMSH_CORE_PWD}/.cmmsh.d/recipe"
CMMSH_RECIPE_DEFAULT_PREFIX=
# CMMSH_RECIPE_PREFIX=
# CMMSH_RECIPE_DIR="${CMMSH_CORE_PREFIX_DIR}/etc/cmmsh/recipe"

cmmsh_recipe_is_absolute() {
    case "${1}" in
        /*) return 0 ;;
    esac
    return 1
}

cmmsh_recipe_to_absolute() {
    if ! cmmsh_recipe_is_absolute "${1}"
    then
        eval "${2}"='"${CMMSH_RECIPE_PREFIX}/${1}"'
    else
        eval "${2}"='"${1}"'
    fi
    # TODO enhance normalization process
    # to resolve relative path with double dot
    # we has to remove it parent dir exclude it name is '.' or '..'
    # but sed doesn't has negative lookahead,
    # so we select the pattern manually
    # for one char string: [^/.]
    # for two char string: [^/.]\. or \.[^/.]
    # for multiple char string: [^/.][^/.][^/]*
    eval "${2}"='"$( sed " :remove-extra-slash s@//*@/@g ;
    :resolve-double-dot s@/\([^/.]\|\.[^/.]\|[^/.]\.\|[^/.][^/.][^/]*\)/\.\.\(/\|$\)@/@ ; t resolve-double-dot ;
    :resolve-single-dot s@/.\(/\|$\)@\1@g ;
    " <<< "${'"${2}"'}" )"'
    # eval '${2}"=$( sed "s@/[^/]*/\.\.\(/\|$\)@\1@g" <<< "${'"${2}"'}" )"'
}

cmmsh_recipe_dependencies() {
    # @param
    # 1. [in] (string) recipe
    # 2. [out] (array) dependencies
    #
    if test -z "${2}" || cmmsh_recipe_load "${1}"
    then
        if test "$( type -t recipe_metadata )" = "function" && recipe_metadata
        then
            eval "${2}"='("${RECIPE_DEPENDENCIES[@]}")'
            return 0
        else
            echo eval "${2}"='()'
            eval "${2}"='()'
        fi
    fi
    return 1
}

cmmsh_recipe_normalized_dependencies() {
    # 1. [in] (string) recipe
    # 2. [out] (array) dependencies
    cmmsh_recipe_dependencies "${1}" "${2}"
    cmmsh_recipe_normalize_recipes "${2}"
}

cmmsh_recipe_exists() {
    # @param
    # $1.recipe:
    # @result
    local __recipe=
    cmmsh_recipe_to_absolute "${1}" __recipe
    # cmmsh_core_info exists: "${@} ${__recipe}"
    if test ! -z "${2}"
    then
        eval "${2}"='"${CMMSH_RECIPE_DIR}${__recipe}"'
    fi
    test -f "${CMMSH_RECIPE_DIR}${__recipe}/recipe.bash"
}

cmmsh_recipe__exists_with_info() {
    if cmmsh_recipe_exists "${@}"
    then
        return 0
    else
        cmmsh_core_warning "cannot find recipe: \"${1}\", ignoring"
        return 1
    fi
}

cmmsh_recipe_normalize_recipes() {
    eval __recipes_='("${'"${1}"'[@]}")'
    eval "${1}"='()'
    for __recipe in "${__recipes_[@]}"
    do
        if cmmsh_recipe_to_absolute "${__recipe}" __recipe
        then
            eval "${1}"+='("${__recipe}")'
        fi
    done
}

cmmsh_recipe_load() {
    local __recipe="${1}"
    local __script=
    if ! cmmsh_recipe_exists "${__recipe}" __script
    then
        return 1
    fi
    source "${__script}/recipe.bash"
}

cmmsh_recipe_unload() {
    unset -f package_help
    unset -f package_metadata
    unset -f package_install
    unset -f package_run
    unset -f package_source
    unset -f package_build
    unset -f package_test
    unset -f package_configure
    unset -f package_compile
    unset -f package_make
    unset -f package_is_installed
}

cmmsh_recipe_install() {
    if cmmsh_recipe_load "${1}"
    then
        if test "$( type -t recipe_is_installed )" = "function" && recipe_is_installed
        then
            cmmsh_core_info "recipe ${1} already installed, skipping"
            cmmsh_recipe_unload "${1}"
            return 0
        else
            cmmsh_core_info "install recipe: ${__recipe}"
            if test "$( type -t recipe_install )" = "function" && recipe_install
            then
                cmmsh_core_info "recipe ${1} installed successfully"
                cmmsh_recipe_unload "${1}"
                return 0
            else
                cmmsh_core_info "recipe ${1} installed failed"
                cmmsh_recipe_unload "${1}"
                return 1
            fi
        fi
    else
        cmmsh_core_warning "cannot find recipe: \"${__recipe}\""
        return 1
    fi
}

cmmsh_recipe_install_recipes() {
    local __recipes_var="${1}"
    local __recipes=()
    eval __recipes='("${'"${__recipes_var}"'[@]}")'
    for __recipe in "${__recipes[@]}"
    do
        cmmsh_recipe_install "${__recipe}"
    done
}

cmmsh_recipe_force_install() {
    if cmmsh_recipe_load "${1}"
    then
        if test "$( type -t recipe_is_installed )" = "function" && recipe_is_installed
        then
            cmmsh_core_info "recipe ${1} already installed, but install forcefully"
        fi
        cmmsh_core_info "install recipe: ${1}"
        if test "$( type -t recipe_install )" = "function" && recipe_install
        then
            cmmsh_core_info "recipe ${1} installed successfully"
            cmmsh_recipe_unload "${1}"
            return 0
        else
            cmmsh_core_info "recipe ${1} installed failed"
            cmmsh_recipe_unload "${1}"
            return 1
        fi
    else
        return 1
    fi
}

cmmsh_recipe_force_install_recipes() {
    local __recipes_var="${1}"
    local __recipes=()
    eval __recipes='("${'"${__recipes_var}"'[@]}")'
    for __recipe in "${__recipes[@]}"
    do
        cmmsh_recipe_force_install "${__recipe}"
    done
}

cmmsh_recipe_install_recipes_with_dependencies() {
    local __recipes_var="${1}"
    local __recipes=()
    local __sorted_=()
    local __cycled_=
    eval __recipes='("${'"${__recipes_var}"'[@]}")'
    cmmsh_recipe_normalize_recipes __recipes
    cmmsh_core_info "resolving recipe dependencies, recipes: [${__recipes[@]}]"
    cmmsh_algorithm_topo_sort_vertexs __recipes cmmsh_recipe_normalized_dependencies __sorted_ __cycled_ cmmsh_recipe__exists_with_info
    for __recipe in "${__sorted_[@]}"
    do
        if cmmsh_map_has_key __cycled_ "${__recipe}"
        then
            cmmsh_map_var_at __cycled_ "${__recipe}" var
            eval arr='("${'"${var}"'[@]}")'
            cmmsh_core_warning "cyclic depencencies detected, recipe ${__recipe} will be install before dependent recipes (${arr[@]})"
        fi
        cmmsh_core_info "resolved recipe: ${__recipe}"
    done
    cmmsh_core_info "dependencies resolved" # "with sorted recipes [${__sorted_[@]}]."
    cmmsh_recipe_install_recipes __sorted_
}

cmmsh_recipe_force_install_recipes_with_dependencies() {
    local __recipes_var="${1}"
    local __recipes=()
    local __sorted_=()
    local __cycled_=
    eval __recipes='("${'"${__recipes_var}"'[@]}")'
    cmmsh_recipe_normalize_recipes __recipes
    cmmsh_core_info "resolving recipe dependencies, recipes: [${__recipes[@]}]"
    cmmsh_algorithm_topo_sort_vertexs __recipes cmmsh_recipe_normalized_dependencies __sorted_ __cycled_ cmmsh_recipe__exists_with_info
    for __recipe in "${__sorted_[@]}"
    do
        if cmmsh_map_has_key __cycled_ "${__recipe}"
        then
            cmmsh_map_var_at __cycled_ "${__recipe}" var
            eval arr='("${'"${var}"'[@]}")'
            cmmsh_core_warning "cyclic depencencies detected, recipe ${__recipe} will be install before dependent recipes (${arr[@]})"
        fi
        cmmsh_core_info "resolved recipe: ${__recipe}"
    done
    cmmsh_core_info "dependencies resolved" # "with sorted recipes [${__sorted_[@]}]."
    cmmsh_recipe_force_install_recipes __sorted_
}

cmmsh_recipe_source() {
    cmmsh_core_info args: "${@}"
    if cmmsh_recipe_load "${1}"
    then
        if test "$( type -t package_source )" = "function"
        then
            shift
            package_metadata
            package_source "${@}"
        fi
    else
        cmmsh_core_warning "cannot find recipe: \"${__recipe}\""
        return 1
    fi
}
