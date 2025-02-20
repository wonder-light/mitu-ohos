# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(myNpmLib)

add_definitions( "-DLOG_DOMAIN=0xFF00" )
add_definitions( "-DLOG_TAG=\"logger\"" )

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

aux_source_directory(${NATIVERENDER_ROOT_PATH}/src CURRENT_SOURCES)

add_library(utils SHARED
    napi_init.cpp
    ${CURRENT_SOURCES}
)
target_link_libraries(utils PUBLIC libace_napi.z.so libhilog_ndk.z.so)
