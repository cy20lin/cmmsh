if test ! -z "${CMMSH_MAP_BASH_REQUIRED}"
then
    return 1
fi
CMMSH_MAP_BASH_REQUIRED=1

# cmmsh_core_require cmmsh/array

cmmsh_map_static_hash_default() {
    cmmsh_map_static_hash_underscore "${@}"
    # local __value="${1}"
    # local __var="${2}"
    # echo value=$__value
    # echo var=$__var
    # if test -z "{__var}"
    # then
    #     return 1
    # fi
    # local __new_value=
    # # __new_value="${__value//[^A-Za-z_]/_}"
    # # if ! __new_value="$( printf "%s" "${__value}" | sed 's@[^A-Za-z0-9_]@_@g' )"
    # # then
    # #     # [FIXME] Dont know why this would fail sometimes in msys2 bash.
    # #     # fallback to this
    # #     __new_value="${__value//[^A-Za-z0-9_]/_}"
    # #     true
    # # fi
    # eval "${__var}"='"${__new_value}"'
}


cmmsh_map_static_hash_xxd() {
    # echo eval "${2}"='"$( cat "${1}" | xxd -pu )"'
    # remove 0a in the end
    # FIXME: xxd may fail
    # sometimes xxd would fail on msys2
    eval "${2}"='"$( xxd -pu <<< "${1}" )" ; '"${2}"='${'"${2}"'::-2}'
}

cmmsh_map_static_hash_underscore() {
    # following command worked on msys2 bash 4.3.046-1, failed on msys2 bash 4.4.019-2
    # eval "${2}"='"$( printf "%s" "${1}" | sed "s@[^0-9A-Za-z_]@_@g" )"'
    # this works on both versions
    eval "${2}"='"${1//[^A-Za-z_]/_}"'
}

cmmsh_map_init() {
    # 1. __map
    local __map="${1}"
    eval "${__map}_type"=cmmsh_map
    eval "${__map}_keys"='()'
    eval "${__map}_at_"='()'
}

cmmsh_map_fini() {
    local __map="${1}"
    local __keys=
    local __key=
    local __var=
    cmmsh_map_keys "${1}" __keys
    for __key in "${__keys[@]}"
    do
        cmmsh_map_var_at "${__map}" "${__key}" __var
        # echo delete key: ${__key} '=>' ${__var}
        unset -v "${__var}"
    done
    unset -v "${__map}"
    unset -v "${__map}_type"
    unset -v "${__map}_keys"
}

cmmsh_map_hash() {
    # 1. map
    # 2. key
    # 3. key_var
    local __map="${1}"
    local __key="${2}"
    local __key_var="${3}"
    if eval test -z '${'"${__map}_hash"'}'
    then
        cmmsh_map_static_hash_default "${__key}" "${__key_var}"
    else
        eval '"${'"${__map}_hash"'}"' '"${__key}"' '"${__key_var}"'
    fi
}

cmmsh_map_var_at() {
    # 1. map
    # 2. out_var
    local __map="${1}"
    local __key="${2}"
    local __out_var="${3}"
    local __new_key=
    cmmsh_map_hash "${__map}" "${__key}" __new_key
    eval "${__out_var}"='"${__map}_at_${__new_key}"'
}

cmmsh_map_at() {
    # 1. map
    # 2. out_var
    local __map="${1}"
    local __key="${2}"
    local __out_var="${3}"
    local __var=
    cmmsh_map_var_at "${__map}" "${__key}" "__var"
    eval "${__out_var}"='"${'"${__var}"'}"'
}

#
cmmsh_map_has_key() {
    local __map="${1}"
    local __key="${2}"
    local __var=
    cmmsh_map_var_at "${__map}" "${__key}" "__var"
    eval test ! -z '"${'"${__var}+HAS_VALUE"'}"'
}

#
cmmsh_map_keys() {
    # local __map="${1}"
    # local __keys="${2}"
    # echo eval "${2}"='("${'"${1}_keys"'[@]}")'
    eval "${2}"='("${'"${1}_keys"'[@]}")'
}

cmmsh_map_keys_count() {
    local __map="${1}"
    local __count="${2}"
    eval "${__count}"='("${#'"${__map}_keys"'[@]}")'
}

cmmsh_map_insert() {
    # 1. map
    # 2. key
    # 3. value
    # result. success or not
    local __map="${1}"
    local __key="${2}"
    local __value="${3}"
    if cmmsh_map_has_key "${__map}" "${__key}"
    then
        return 1
    else
        # echo assign $__key = $__value
        cmmsh_map_insert_or_assign "${__map}" "${__key}" "${__value}"
    fi
}

cmmsh_map_insert_or_assign() {
    local __map="${1}"
    local __key="${2}"
    local __value="${3}"
    local __var=
    eval "${__map}_keys"+='("${__key}")'
    # eval echo key '${'"${__map}_keys"'[@]}'
    cmmsh_map_var_at "${__map}" "${__key}" "__var"
    eval "${__var}"='"${__value}"'
}

cmmsh_map_remove() {
    # 1. map
    # 2. key
    # result. success or not
    local __map="${1}"
    local __key="${2}"
    local __value="${3}"
    local __var=
    if cmmsh_map_has_key "${__map}" "${__key}"
    then
        cmmsh_array_remove "${__map}_keys" "${__key}"
        cmmsh_map_var_at "${__map}" "${__key}" "__var"
        unset "${__var}"
    else
        return 1
    fi
}
