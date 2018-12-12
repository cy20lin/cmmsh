if test ! -z "${CMMSH_DOTCMMSH_BASH_INCLUDED}"
then
    return 1
fi
CMMSH_DOTCMMSH_BASH_INCLUDED=1

cmmsh_dotcmmsh__init_with_dir() {
    if test ! -z "${1}" -a -f "${1}/init.bash"
    then
        # cmmsh_core_info "loading user config file"
        if source "${1}/init.bash"
        then
            # cmmsh_core_info "user config file loaded"
            true
        else
            cmmsh_core_error "user config file loading failure"
            return 1
        fi
    else
        cmmsh_core_error "user config file .cmmsh.d/init.bash not found"
        return 1
    fi
    shift
    if test "$( type -t dotcmmsh_init )" = "function"
    then
        # cmmsh_core_info "dotcmmsh_init loading"
        shift
        if dotcmmsh_init "${@}"
        then
            # cmmsh_core_info "dotcmmsh_init loaded"
            return 0
        else
            cmmsh_core_error "dotcmmsh_init loaded failure"
            return 1
        fi
    else
        cmmsh_core_error "function dotcmmsh_init not found in user config file .cmmsh.d/init.bash"
        return 1
    fi
}

cmmsh_dotcmmsh_init() {
    if cmmsh_dotcmmsh__init_with_dir "${CMMSH_CORE_DOTCMMSH_DIR}" "${@}"
    then
        return 0
    else
        return 1
    fi
}
