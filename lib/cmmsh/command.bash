if test ! -z "${CMMSH_COMMAND_BASH_INCLUDED}"
then
    return 1
fi
CMMSH_COMMAND_BASH_INCLUDED=1

cmmsh_command() {
    local CMMSH_COMMAND="${1}"
    shift
    local ARGV=("${@}")
    if cmmsh_core_include "cmmsh/command/${CMMSH_COMMAND[@]}"
    then
        command_entry "${ARGV[@]}"
    else
        cmmsh_core_include cmmsh/command/help && command_entry "${ARGV[@]}"
    fi
}
