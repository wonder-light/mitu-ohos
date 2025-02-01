# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(myNpmLib)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)


# FILE(GLOB_RECURSE CURRENT_SOURCES ${NATIVERENDER_ROOT_PATH}/src/*.cpp)
aux_source_directory(${NATIVERENDER_ROOT_PATH}/src CURRENT_SOURCES)
# add_executable(eval_js ${CURRENT_SOURCES} ${CURRENT_INCLUDE})  #制定生成目标


add_library(eval_js SHARED
    napi_init.cpp
    #src/jsvm.cpp
    #src/utils.cpp
    ${CURRENT_SOURCES}
)

# 加了 libjsvm.so 会报错
target_link_libraries(eval_js PUBLIC libace_napi.z.so libjsvm.so libhilog_ndk.z.so)
