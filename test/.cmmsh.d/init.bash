is_msys2() {
    test ! -z "${MSYSTEM}"
}

is_ubuntu() {
    command -v apt-get 1>/dev/null
}

is_archlinux() {
    command -v pacman 1>/dev/null
}

dotcmmsh_init() {
    CMMSH_LAYER_PREFIX=/recipe
    # if is_msys2
    # then
    #     CMMSH_LAYER_PREFIX=/msys2
    # elif is_ubuntu
    # then
    #     CMMSH_LAYER_PREFIX=/ubuntu
    # elif is_archlinux
    # then
    #     CMMSH_LAYER_PREFIX=/archlinux
    # else
    #     CMMSH_LAYER_PREFIX=/default
    # fi
}
