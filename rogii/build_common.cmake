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

set(
    PROJECT_ROOT_PATH
    "${CMAKE_CURRENT_LIST_DIR}/.."
)

set(
    ROGII_FOLDER_PATH
    "${CMAKE_CURRENT_LIST_DIR}"
)

include(
    "${ROGII_FOLDER_PATH}/version.cmake"
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
    BUILD_PATH
    "${PROJECT_ROOT_PATH}/build"
)

file(
    MAKE_DIRECTORY
    "${BUILD_PATH}"
)

execute_process(
    COMMAND
        ${CMAKE_COMMAND} -G Ninja -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} ${PROJECT_ROOT_PATH}
    WORKING_DIRECTORY
        ${BUILD_PATH}
)

execute_process(
    COMMAND
        ${CMAKE_COMMAND} --build . --target build_target
    WORKING_DIRECTORY
        ${BUILD_PATH}
)

if(UNIX)
    execute_process(
        COMMAND
            bash -c "rm -rf *.a"
        WORKING_DIRECTORY
            "${CMAKE_INSTALL_PREFIX}/lib"
    )
    execute_process(
        COMMAND
            bash -c "rm -rf *.so"
        WORKING_DIRECTORY
            "${CMAKE_INSTALL_PREFIX}/lib"
    )

    file(GLOB files "${CMAKE_INSTALL_PREFIX}/lib/*.so*")
    foreach(file ${files})
        execute_process(
            COMMAND
                bash ${ROGII_FOLDER_PATH}/utils/split_debug_info.sh "${file}"
            WORKING_DIRECTORY
                "${CMAKE_INSTALL_PREFIX}/lib"
        )
    endforeach()
endif()

file(
    COPY
        "${ROGII_FOLDER_PATH}/package.cmake"
    DESTINATION
        "${CMAKE_INSTALL_PREFIX}"
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
