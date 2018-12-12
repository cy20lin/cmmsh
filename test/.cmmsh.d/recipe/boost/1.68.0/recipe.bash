package_metadata() {
    package_name=boost
    package_verson=1.68.0
    package_dependencies=(
    )
    package_build_dependencies=(
    )

    package_archive_url="https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz"
    package_archive_name=boost_1_68_0
    package_archive_type=.tar.gz
    package_archive_file_name="${package_archive_name}${package_archive_type}"

}

package_source() {
    # cmmsh_action download_file "${package_archive_url}"
    cmmsh_action git_clone "https://github.com/fmtlib/fmt"
    cmmsh_action git_checkout_commit 639de21757e10f2b080a62ca0761fdb3b5466c35
    # cmmsh_action archive .tar.gz
    # cmmsh_action unarchive .tar.gz
    cmmsh_action rebase .git
    # cmmsh_action_store_source
}

package_build() {
    false
}

package_install() {
    false
}
