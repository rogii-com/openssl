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

# 'd' has index 3
set(
    PACKAGE_NAME
    "openssl-1.1.1.3-${ARCH}-${BUILD}${TAG}"
)

set(
    DEBUG_PATH
    ${CMAKE_CURRENT_LIST_DIR}/../build/debug_${ARCH}
)

file(
    MAKE_DIRECTORY
    ${DEBUG_PATH}
)

if(UNIX)
    execute_process(
        COMMAND
            perl Configure shared no-asm ${CONFIG_ARCH} --prefix=${ROOT}/${PACKAGE_NAME} --openssldir=${ROOT}/${PACKAGE_NAME}/ssl
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
                bash ${CMAKE_CURRENT_SOURCE_DIR}/cmake/split_debug_info.sh "${file}"
            WORKING_DIRECTORY
                "${ROOT}/${PACKAGE_NAME}/lib/"
        )
    endforeach()
        execute_process(
        COMMAND
            bash -c "chmod u+w ${ROOT}/${PACKAGE_NAME}/lib/engines/lib*"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    file(GLOB files "${ROOT}/${PACKAGE_NAME}/lib/engines/*.so*")
    foreach(file ${files})
        execute_process(
            COMMAND
                bash ${CMAKE_CURRENT_SOURCE_DIR}/cmake/split_debug_info.sh "${file}"
            WORKING_DIRECTORY
                "${ROOT}/${PACKAGE_NAME}/lib/engines"
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
            bash -c "chmod -wx ${ROOT}/${PACKAGE_NAME}/lib/engines/lib*"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
elseif(WIN32)
    execute_process(
        COMMAND
            ${CMAKE_COMMAND} -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_LIST_DIR}/../${PACKAGE_NAME} ../..
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

execute_process(
    COMMAND
        ${CMAKE_COMMAND} -E tar cf ${ROOT}/${PACKAGE_NAME}.7z --format=7zip -- ${PACKAGE_NAME}
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_LIST_DIR}/..
)

