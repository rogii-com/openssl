cmake_minimum_required(
    VERSION
    3.12.4
)

project(
    OpenSSL
    LANGUAGES
        C
)

include(
    ${PROJECT_SOURCE_DIR}/cmake/cnpm/NastyPackageManager.cmake
)

NPM_ADD_PACKAGE(
    NAME
        msvs
    VERSION
        2019
    ARCHITECTURE
        amd64
    BUILD_NUMBER
        1
    TAG
        "exp1"
)

NPM_ADD_PACKAGE(
    NAME
        WindowsSDK
    VERSION
        10.0.18362.0
    ARCHITECTURE
        amd64
    BUILD_NUMBER
        0
)

NPM_PREPARE_PACKAGES(
    DEFAULT_REPOSITORY_URLS
        "https://cnpm.rogii.com/windows/public"
)

set(
    OPENSSL_CONFIG_ARCH
    "VC-WIN32"
)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(
        OPENSSL_CONFIG_ARCH
        "VC-WIN64A"
    )
endif()

add_custom_command(
    OUTPUT
        ${PROJECT_BINARY_DIR}/build
    COMMAND
        ${CMAKE_COMMAND}
        -E
        make_directory
        ${PROJECT_BINARY_DIR}/build
    COMMENT
        "Create build directory for legacy build system."
    WORKING_DIRECTORY
        ${PROJECT_BINARY_DIR}
)

add_custom_command(
    OUTPUT
        ${PROJECT_BINARY_DIR}/build/configdata.pm
    COMMAND
        perl
        ${PROJECT_SOURCE_DIR}/Configure
        no-asm
        no-dynamic-engine
        ${OPENSSL_CONFIG_ARCH}
        --prefix=${CMAKE_INSTALL_PREFIX}
        --openssldir=${CMAKE_INSTALL_PREFIX}/ssl
    COMMENT
        "Run configure script."
    DEPENDS
        ${PROJECT_BINARY_DIR}/build
    WORKING_DIRECTORY
        ${PROJECT_BINARY_DIR}/build
)

add_custom_target(
    build_target
    COMMAND
        ${CMAKE_COMMAND}
        -E
        env
        LIBS=apps\\libapps.lib
        ${CMAKE_MAKE_PROGRAM}
        /E
        install_sw
    COMMAND
        ${CMAKE_COMMAND}
        -E
        copy
        ${PROJECT_SOURCE_DIR}/cmake/package.cmake
        ${CMAKE_INSTALL_PREFIX}
    COMMENT
        "Build OpenSSL."
    DEPENDS
        ${PROJECT_BINARY_DIR}/build/configdata.pm
    WORKING_DIRECTORY
        ${PROJECT_BINARY_DIR}/build
)

