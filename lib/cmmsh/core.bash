if test ! -z "${CMMSH_CORE_BASH_INCLUDED}"
then
    return 1
fi
CMMSH_CORE_BASH_INCLUDED=1
CMMSH_CORE_PREFIX_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
CMMSH_CORE_PWD="${PWD}"
CMMSH_CORE_DOTCMMSH_DIR="${PWD}/.cmmsh.d"
CMMSH_CORE_WORKSPACE_DIR="${PWD}/.cmmsh"

cmmsh_core_include__with_dir() {
    # local __module="${1}"
    # local __file="${2}/lib/${__module}.bash"
    if test -f "${2}/lib/${1}.bash"
    then
        source "${2}/lib/${1}.bash"
        return 0
    else
        return 1
    fi
}

cmmsh_core_include() {
    cmmsh_core_include__with_dir "${1}" "${CMMSH_CORE_PREFIX_DIR}" \
        || cmmsh_core_include__with_dir "${1}" "${CMMSH_CORE_DOTCMMSH_DIR}"
}

cmmsh_core_print() {
    echo "${@}"
}

cmmsh_core_info() {
    test CMMSH_DEBUG && echo "[cmmsh][info]" "${@}" 1>&2
}

cmmsh_core_warning() {
    echo "[cmmsh][warning]" "${@}" 1>&2
}

cmmsh_core_error() {
    echo "[cmmsh][error]" "${@}" 1>&2
}

cmmsh_timestamp() {
    # date +%Y%m%d-%H%M%S.%N%z
    date +%Y%m%d-%H%M%S%z
}

cmmsh_log() {
    _namespace="${1}"
    _date="$(cmmsh_timestamp)"
    _prefix="[${_date}][${_namespace}]"
    shift
    echo "${_prefix}" "$@"
}
