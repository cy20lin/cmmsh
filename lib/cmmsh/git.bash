if test ! -z "${CMMSH_GIT_BASH_INCLUDED}"
then
    return 1
fi
CMMSH_GIT_BASH_INCLUDED=1

cmmsh_git_has_commit() {
    local commit="${1}"
    git cat-file -e "${commit}^{commit}"
}

cmmsh_git_get_full_sha1() {
    sha="${1}"
    git rev-parse "${sha}^{commit}"
}

cmmsh_git_clone_without_checkout() {
    url="${1}"
    dst="${2}"
    git clone -n "${url}" "${dst}"
}

cmmsh_git_remote_origin_up_to_date() {
    dir="${1}"
    cd "${dir}" && git remote show origin | grep 'up to date'
}

cmmsh_git_is_valid_non_bare_repo() {
    # true
    dir="${1}"
    cd "${dir}" \
        && test -d .git \
        && test "`cd .git && pwd`" = "`cd $(git rev-parse --git-dir) && pwd`" \
        && git rev-parse --is-inside-work-tree
}

cmmsh_git_allow_reachable_sha1_in_want() {
    dir="${1}"
    cd "${dir}" \
        && cmmsh_git_is_valid_non_bare_repo . \
        && git config uploadpack.allowReachableSHA1InWant true
}

cmmsh_git_checkout_specific_commit() {
    src="${1}"
    dst="${2}"
    sha="${3}"
    src_="`cd "${src}" && pwd`"
    dst_="`cd "${dst}" && pwd`"
    echo "${src_}"
    echo "${dst_}"
    cwd="$(pwd)"
    mkdir -p "${dst_}" && cd "${dst_}" && git init \
        && git fetch --depth 1 "${src_}" "${sha}" \
        && git checkout FETCH_HEAD
}
