cmake_minimum_required(VERSION 3.15)
project(CppTemplate CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 确保使用正确的编译器
if(NOT CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER "gcc")
endif()
if(NOT CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_COMPILER "g++")
endif()

# 查找依赖包
find_package(yaml-cpp CONFIG REQUIRED)

# 添加可执行文件
add_executable(${PROJECT_NAME} main.cpp)

# 链接依赖库
target_link_libraries(${PROJECT_NAME} PRIVATE yaml-cpp::yaml-cpp) 