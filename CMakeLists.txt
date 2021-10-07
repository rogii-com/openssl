cmake_minimum_required(
    VERSION
    3.12.4
)

project(
    OpenSSL
    LANGUAGES
        C
)

set(
    ROGII_FOLDER_PATH
    "${CMAKE_CURRENT_LIST_DIR}/rogii"
)
include(${ROGII_FOLDER_PATH}/npm/Include.cmake)
include(${ROGII_FOLDER_PATH}/environment.cmake)

CNPM_PREPARE_PACKAGES(
    DEFAULT_REPOSITORY_URLS
    "$ENV{CNPM_URLS}"
)

if(WIN32)
    set(
        PLATFORM_MAKE_PROGRAM
        "nmake"
    )

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(
            OPENSSL_CONFIG_ARCH
            "VC-WIN64A"
        )
    else()
        set(
            OPENSSL_CONFIG_ARCH
            "VC-WIN32"
        )
    endif()
elseif(UNIX)
    set(
        PLATFORM_MAKE_PROGRAM
        "make"
    )

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(
            OPENSSL_CONFIG_ARCH
            "linux-x86_64"
        )
    else()
        message(FATAL_ERROR "Unsupported arch")
    endif()
else()
    message(FATAL_ERROR "Unsupported platform")
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
        ${PLATFORM_MAKE_PROGRAM} install_sw
    COMMENT
        "Build OpenSSL."
    DEPENDS
        ${PROJECT_BINARY_DIR}/build/configdata.pm
    WORKING_DIRECTORY
        ${PROJECT_BINARY_DIR}/build
)
