if test ! -z "${CMMSH_ACTION_BASH_INCLUDED}"
then
    return 1
fi
CMMSH_ACTION_BASH_INCLUDED=1

# CMM_ACTION_OPTION_source=
# CMM_ACTION_OPTION_destination=
# CMM_ACTION_OPTION_argument=
# CMM_ACTION_OPTION_argument=

cmmsh_core_include cmmsh/fs
cmmsh_core_include cmmsh/git

cmmsh_action_git_clone() {
    local url="${1}"
    local srcdir="${PWD}"
    local dstdir="$(cmmsh_fs_get_cache_dir cache/repository "${1}" )"
    if ! cd "${dstdir}"
    then
        return $?
    fi
    if cmmsh_fs_is_empty_dir "${dstdir}"
    then
        git clone -n "${url}" . && git config uploadpack.allowReachableSHA1InWant true
    fi
}

cmmsh_action_git_checkout_commit() {
    local srcdir="${PWD}"
    local dstdir="$(cmmsh_fs_get_temporary_dir)"
    local commit="${1}"
    local has_commit=
    cmmsh_git_has_commit "${commit}"
    has_commit=$?
    if ! cd "${dstdir}"
    then
        return $?
    fi
    if test "${PWD}" = "${srcdir}"
    then
        git checkout "${commit}"
        return $?
    fi
    # try fetch specific commit at local repository
    if test "${has_commit}" = 0
    then
        git init && git fetch "${srcdir}" --depth 1 "${commit}" && git checkout FETCH_HEAD
        return $?
    fi
    # if not found: checkout local repository is up-to-date
    if ! ( git remote show origin | grep 'up to date' )
    then
        # if not: update it
        if pushd "${srcdir}"
        then
            # if update success
            if git pull && git config uploadpack.allowReachableSHA1InWant true
            then
                # then try fetch again
                git fetch  --depth 1 "${commit}" && git checkout FETCH_HEAD
            fi
            popd
        fi
    fi
}

cmmsh_action_download_file() {
    local srcdir="${PWD}"
    local url="${1}"
    local dstdir="$(cmmsh_fs_get_cache_dir cache/file "${1}" )"
    local file_name="${2}"
    cmmsh_core_info "donwload_file +++ ${dstdir}"
    cd "${dstdir}"
    pwd
    if test -z "${file_name}"
    then
        wget "${url}"
    else
        wget -O "${file_name}" "${url}"
    fi
}

cmmsh_action_rebase() {
    local srcdir="${PWD}"
    local dstdir="$(cmmsh_fs_get_temporary_dir)"
    local rebase_dir="${1}"
    if ! cd "${dstdir}"
    then
        return $?
    fi
    if test -z "${rebase_dir}"
    then
        cp -a "${srcdir}/." .
    else
        cp -a "${srcdir}/${rebase_dir}/." .
    fi
}

cmmsh_action_unarchive() {
    local srcdir="${PWD}"
    local file="$(cmmsh_fs_find_latest_file_in_dir .)"
    local dstdir="$(cmmsh_fs_get_temporary_dir)"
    local type="${1}"
    local file_name="${2}"
    if test -z "${file_name}"
    then
        file="${srcdir}/$(cmmsh_fs_find_latest_file_in_dir .)"
    else
        file="${srcdir}/${file_name}"
    fi
    cd "${dstdir}"
    pwd
    case "${type}" in
        .tar) tar -xzf "${file}" ;;
        .tar.gz|.tgz) tar -xzf "${file}" ;;
        .gz) gz -d "${file}";;
        .tar.xz|.txz) tar -xJf "${file}" ;;
        .xz) xz -d "${file}";;
        .tar.bz2|.tbz|.tbz2) tar -xjf "${file}" ;;
        .bz2) bzip2 -d "${file}" ;;
        .zip) unzip "${file}" ;;
    esac
}

cmmsh_action_archive() {
    local srcdir="${PWD}"
    local file="$(cmmsh_fs_find_latest_file_in_dir .)"
    local dstdir="$(cmmsh_fs_get_temporary_dir)"
    local type="${1}"
    local file_name="${2}"
    local in_file_name="${3}"
    if test -z "${file_name}"
    then
        file="${dstdir}/archive${type}"
    else
        file="${dstdir}/${file_name}"
    fi
    cd "${dstdir}"
    pwd
    case "${type}" in
        .tar) tar -cf "${file}" -C "${srcdir}" . ;;
        .tar.gz|.tgz) tar -czf "${file}" -C "${srcdir}" . ;;
        .tar.bz2|.tbz|.tbz2) tar -cjf "${file}" -C "${srcdir}" . ;;
        .tar.xz|.txz) tar -cJf "${file}" -C "${srcdir}" . ;;
        .gz) gzip -ckf "${in_file_name}" > "${file}" ;;
        .gz) xz -ckf "${in_file_name}" > "${file}" ;;
        .bz2) bzip2 -d "${in_file_name}" > "${file}" ;;
        .zip) zip -r "${in_file_name}" "${srcdir/}/${file}"  ;;
    esac
}

cmmsh_action() {
    cmmsh_core_info "action: ${@}"
    case "${1}" in
        git_clone) shift ; cmmsh_action_git_clone "${@}" ;;
        git_checkout) shift ; cmmsh_action_git_checkout "${@}" ;;
        git_checkout_commit) shift ; cmmsh_action_git_checkout_commit "${@}" ;;
        clone|rebase) shift ; cmmsh_action_rebase "${@}" ;;
        archive) shift ; cmmsh_action_archive "${@}" ;;
        unarchive) shift ; cmmsh_action_unarchive "${@}" ;;
        download_file) shift ; cmmsh_action_download_file "${@}" ;;
    esac
    pwd
}
