if test ! -z "${CMMSH_FS_BASH_INCLUDED}"
then
    return 1
fi
CMMSH_FS_BASH_INCLUDED=1

cmmsh_fs_is_empty_dir() {
    if test -z "${1}"
    then
        local files="$(ls -1A)" && test -z "${files}"
    else
        local files="$(ls "${1}" -1A)" && test -z "${files}"
    fi
}

cmmsh_fs_find_latest_file_in_dir() {
    if test -z "${1}"
    then
        ls -t | awk '{printf("%s\n",$0);exit}'
    else
        ls "${1}" -t | awk '{printf("%s\n",$0);exit}'
    fi
}

cmmsh_fs_get_temporary_dir() {
    local prefix="${1}"
    local suffix="${2}"
    if test -z "${prefix}"
    then
        prefix=tmp
    fi
    mkdir -p "${CMMSH_CORE_WORKSPACE_DIR}/${prefix}"
    mktemp -d -p "${CMMSH_CORE_WORKSPACE_DIR}/${prefix}"
}

cmmsh_fs_get_cache_dir_path() {
    prefix="${1}"
    suffix="${2}"
    echo "${suffix}" | sed "s/[^a-zA-Z0-9_.]/@/g" | xargs printf "${CMMSH_CORE_WORKSPACE_DIR}/${prefix}/%s\n"
    # cmmsh_fs_is_empty_dir
}

cmmsh_fs_get_empty_cache_dir() {
    local _path="$(cmmsh_fs_get_cache_dir_path "${@}" )"
    mkdir -p "${_path}"
    local _result=$?
    $(cd "${path}" ; rm * -rf)
    echo "${_path}"
    return "${_result}"
}

cmmsh_fs_get_cache_dir() {
    local _path="$(cmmsh_fs_get_cache_dir_path "${@}" )"
    echo "${_path}"
    mkdir -p "${_path}"
}

cmmsh_fs_has_store_dir_path() {
    local _namespace="${1}"
    local _name="${2}"
    local _version="${3}"
    printf '%s' "${CMMSH_CORE_WORKSPACE_DIR}/${_namespace}/${_name}/${_version}"
    shift
    shift
    shift
    for _hash in "${@-default}"
    do
        if test -z "${_hash}"
        then
            break;
        fi
        printf '/%s/0' "${_hash}"
    done
    printf '\n'
}

cmmsh_fs_ensure_dir() {
    mkdir -p "${1}"
}

cmmsh_fs_hash() {
    find . -type f \( -exec sha1sum "$PWD"/{} \; \) | awk '{print $1}' | sort | sha1sum
}

cmmsh_fs_clear_store() {
    if ! test -z "${CMMSH_CORE_WORKSPACE_DIR}"
    then
        rm -rf -- "${CMMSH_CORE_WORKSPACE_DIR}/store/*"
    fi
}

cmmsh_fs_clear_cache() {
    if ! test -z "${CMMSH_CORE_WORKSPACE_DIR}"
    then
        rm -rf -- "${CMMSH_CORE_WORKSPACE_DIR}/cache/*"
    fi
}

cmmsh_fs_clear_tmp() {
    if ! test -z "${CMMSH_CORE_WORKSPACE_DIR}"
    then
        rm -rf -- "${CMMSH_CORE_WORKSPACE_DIR}/tmp/*"
    fi
}
