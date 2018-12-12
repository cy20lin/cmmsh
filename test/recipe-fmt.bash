package_metadata() {
    package_name=fmt
    package_verson=1.68.0
    # package_cvs=none
    # package_repository=
    package_dependencies=(
    )
    package_build_dependencies=(
    )
    package_archive_url="https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz"
    package_archive_name=boost_1_68_0
    package_archive_type=.tar.gz
    package_archive_file_name="${package_archive_name}${package_archive_type}"
    package_description="C++ boost library"

}


package_source() {
    cmmsh_action_unarchive .tar.gz
    cmmsh_action_rebase boost_1_68_0
    cmmsh_package_provide
}

package_get_version() {
    echo "${package_version}"
}

package_configure() {
    cmake ${PACKAGE_SOURCE_DIR}
}

package_compile() {
    true
}

package_build() {
    cmmsh_package_run configure
    cmmsh_package_run compile
}

package_install() {
    true
}
