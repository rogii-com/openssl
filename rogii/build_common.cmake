if(
    NOT DEFINED ROOT
    OR NOT DEFINED ARCH
)
    message(
        FATAL_ERROR
        "Assert: ROOT = ${ROOT}; ARCH = ${ARCH}"
    )
endif()

set(
    BUILD
    0
)

if(DEFINED ENV{BUILD_NUMBER})
    set(
        BUILD
        $ENV{BUILD_NUMBER}
    )
endif()

set(
    TAG
    ""
)

if(DEFINED ENV{TAG})
    set(
        TAG
        "$ENV{TAG}"
    )
else()
    find_package(
        Git
    )

    if(Git_FOUND)
        execute_process(
            COMMAND
                ${GIT_EXECUTABLE} rev-parse --short HEAD
            OUTPUT_VARIABLE
                TAG
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        set(
            TAG
            "_${TAG}"
        )
    endif()
endif()

include(
    "${CMAKE_CURRENT_LIST_DIR}/version.cmake"
)

set(
    BUILD_PATH
    "${CMAKE_CURRENT_LIST_DIR}/../build"
)

set(
    PACKAGE_NAME
    "openssl-${ROGII_PKG_VERSION}-${ARCH}-${BUILD}${TAG}"
)

set(
    CMAKE_INSTALL_PREFIX
    ${ROOT}/${PACKAGE_NAME}
)

set(
    DEBUG_PATH
    "${BUILD_PATH}/debug"
)

set(
    RELEASE_PATH
    "${BUILD_PATH}/release"
)

file(
    MAKE_DIRECTORY
    "${DEBUG_PATH}"
)

file(
    MAKE_DIRECTORY
    "${RELEASE_PATH}"
)

if(UNIX)
    set(
        CONFIG_ARCH
        linux-x86_64
    )
endif()

if(UNIX)
    execute_process(
        COMMAND
            perl ./Configure shared no-asm ${CONFIG_ARCH} --prefix=${ROOT}/${PACKAGE_NAME} --openssldir=${ROOT}/${PACKAGE_NAME}/ssl
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    execute_process(
        COMMAND
            make -j1 build_apps
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    execute_process(
        COMMAND
            make install_sw INSTALLPREFIX=${ROOT}/${PACKAGE_NAME}
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )        
    execute_process(
        COMMAND
            bash -c "rm -rf ${ROOT}/${PACKAGE_NAME}/lib/*.a"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    execute_process(
        COMMAND
            bash -c "rm -rf ${ROOT}/${PACKAGE_NAME}/lib/*.so"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )

    execute_process(
        COMMAND
            bash -c "chmod u+w ${ROOT}/${PACKAGE_NAME}/lib/lib*"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    file(GLOB files "${ROOT}/${PACKAGE_NAME}/lib/*.so*")
    foreach(file ${files})
        execute_process(
            COMMAND
                bash ${CMAKE_CURRENT_SOURCE_DIR}/rogii/utils/split_debug_info.sh "${file}"
            WORKING_DIRECTORY
                "${ROOT}/${PACKAGE_NAME}/lib/"
        )
    endforeach()
        execute_process(
        COMMAND
            bash -c "chmod u+w ${ROOT}/${PACKAGE_NAME}/lib/engines-1.1/*.so*"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    file(GLOB files "${ROOT}/${PACKAGE_NAME}/lib/engines-1.1/*.so*")
    foreach(file ${files})
        execute_process(
            COMMAND
                bash ${CMAKE_CURRENT_SOURCE_DIR}/rogii/utils/split_debug_info.sh "${file}"
            WORKING_DIRECTORY
                "${ROOT}/${PACKAGE_NAME}/lib/engines-1.1"
        )
    endforeach()
    execute_process(
        COMMAND
            bash -c "chmod -wx ${ROOT}/${PACKAGE_NAME}/lib/lib*"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    execute_process(
        COMMAND
            bash -c "chmod -wx ${ROOT}/${PACKAGE_NAME}/lib/engines-1.1/*.so*"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
elseif(WIN32)
    execute_process(
        COMMAND
            ${CMAKE_COMMAND} -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX=${ROOT}/${PACKAGE_NAME} ../..
        WORKING_DIRECTORY
            ${DEBUG_PATH}
    )

    execute_process(
        COMMAND
            ${CMAKE_COMMAND} --build . --target build_target
        WORKING_DIRECTORY
            ${DEBUG_PATH}
    )
endif()

file(
    COPY
        "${CMAKE_CURRENT_LIST_DIR}/package.cmake"
    DESTINATION
        "${ROOT}/${PACKAGE_NAME}"
)

file(
    REMOVE_RECURSE
    "${BUILD_PATH}"
)

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" -E tar cf "${PACKAGE_NAME}.7z" --format=7zip -- "${PACKAGE_NAME}"
    WORKING_DIRECTORY
        "${ROOT}"
)

