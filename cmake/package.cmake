if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(
        OPENSSL_CRYPTO_LIBRARY_NAME
        "libcrypto.so.1.1"
    )
    set(
        OPENSSL_SSL_LIBRARY_NAME
        "libssl.so.1.1"
    )
endif()

if(NOT TARGET OpenSSL::crypto)
    add_library(
        OpenSSL::crypto
        SHARED
        IMPORTED
    )
    if(MSVC)
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(
				OPENSSL_SUFFIX
				"-x64"
			)
		else()
			set(
				OPENSSL_SUFFIX
				""
			)
		endif()
        set_target_properties(
            OpenSSL::crypto
            PROPERTIES
                IMPORTED_LOCATION
                    ${CMAKE_CURRENT_LIST_DIR}/bin/libcrypto-1_1${OPENSSL_SUFFIX}.dll
                IMPORTED_IMPLIB
                    ${CMAKE_CURRENT_LIST_DIR}/lib/libcrypto.lib
                INTERFACE_INCLUDE_DIRECTORIES
                    ${CMAKE_CURRENT_LIST_DIR}/include
        )
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set_target_properties(
            OpenSSL::crypto
            PROPERTIES
                IMPORTED_LOCATION
                    "${CMAKE_CURRENT_LIST_DIR}/lib/${OPENSSL_CRYPTO_LIBRARY_NAME}"
                INTERFACE_INCLUDE_DIRECTORIES
                    "${CMAKE_CURRENT_LIST_DIR}/include"
        )
    endif()
endif()

if(NOT TARGET OpenSSL::ssl)
    add_library(
        OpenSSL::ssl
        SHARED
        IMPORTED
    )
    if(MSVC)
		if(CMAKE_SIZEOF_VOID_P EQUAL 8)
			set(
				OPENSSL_SUFFIX
				"-x64"
			)
		else()
			set(
				OPENSSL_SUFFIX
				""
			)
		endif()
        set_target_properties(
            OpenSSL::ssl
            PROPERTIES
                IMPORTED_LOCATION
                    ${CMAKE_CURRENT_LIST_DIR}/bin/libssl-1_1${OPENSSL_SUFFIX}.dll
                IMPORTED_IMPLIB
                    ${CMAKE_CURRENT_LIST_DIR}/lib/libssl.lib
                INTERFACE_INCLUDE_DIRECTORIES
                    ${CMAKE_CURRENT_LIST_DIR}/include
        )
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set_target_properties(
            OpenSSL::ssl
            PROPERTIES
                IMPORTED_LOCATION
                    "${CMAKE_CURRENT_LIST_DIR}/lib/${OPENSSL_SSL_LIBRARY_NAME}"
                INTERFACE_INCLUDE_DIRECTORIES
                    "${CMAKE_CURRENT_LIST_DIR}/include"
        )
    endif()
endif()

set(
    COMPONENT_NAMES

    CNPM_RUNTIME_OpenSSL_crypto
)

foreach(COMPONENT_NAME ${COMPONENT_NAMES})
    install(
        FILES
            $<TARGET_FILE:OpenSSL::crypto>
        DESTINATION
            .
        COMPONENT
            ${COMPONENT_NAME}
        EXCLUDE_FROM_ALL
    )
endforeach()

# OpenSSL::ssl dependens on crypto, so one must not have
# chance to install it separetely
set(
    COMPONENT_NAMES

    CNPM_RUNTIME_OpenSSL_ssl
    CNPM_RUNTIME_OpenSSL
    CNPM_RUNTIME
)

foreach(COMPONENT_NAME ${COMPONENT_NAMES})
    install(
        FILES
            $<TARGET_FILE:OpenSSL::crypto>
            $<TARGET_FILE:OpenSSL::ssl>
        DESTINATION
            .
        COMPONENT
            ${COMPONENT_NAME}
        EXCLUDE_FROM_ALL
    )
endforeach()

