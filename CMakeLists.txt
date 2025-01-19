cmake_minimum_required(VERSION 3.10)
project(CppTemplate)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# vcpkg 集成
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "")
endif()

# 查找依赖包
find_package(yaml-cpp CONFIG REQUIRED)

# 添加可执行文件
add_executable(${PROJECT_NAME} main.cpp)

# 链接依赖库
target_link_libraries(${PROJECT_NAME} PRIVATE yaml-cpp) 