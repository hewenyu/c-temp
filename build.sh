#!/bin/bash

# 确保脚本在错误时停止
set -e

# 删除旧的构建目录
rm -rf build

# 创建新的构建目录
mkdir build
cd build

# 确保 Conan profile 存在
conan profile detect --force

# 安装依赖（使用 Release 配置）
conan install .. --build=missing -s build_type=Release

# 配置项目
cmake .. -DCMAKE_TOOLCHAIN_FILE=./Release/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release

# 构建项目
cmake --build . --config Release

echo "Build completed successfully!" 