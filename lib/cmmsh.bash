#!/bin/bash

cmmsh() {
    source "$( dirname "${BASH_SOURCE[0]}" )/../lib/cmmsh/core.bash"
    cmmsh_core_include cmmsh/fs
    cmmsh_core_include cmmsh/action
    cmmsh_core_include cmmsh/dotcmmsh
    cmmsh_core_include cmmsh/command
    cmmsh_dotcmmsh_init "${@}"
    cmmsh_command "${@}"
}

test "${BASH_SOURCE[0]}" = "${0}" && cmmsh "${@}"
