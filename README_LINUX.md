# Linux C++ 开发环境配置指南

本指南介绍如何在 Linux 系统上配置 C++ 开发环境。

## 1. 安装必要的编译工具

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install build-essential gdb cmake git

# CentOS/RHEL
sudo yum groupinstall "Development Tools"
sudo yum install cmake git
```

## 2. 安装 vcpkg

### 下载和安装
```bash
# Clone vcpkg repository
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg

# Run the bootstrap script
./bootstrap-vcpkg.sh

# Add vcpkg root to environment variables (添加到 ~/.bashrc)
echo "export VCPKG_ROOT=$HOME/vcpkg" >> ~/.bashrc
echo "export PATH=\$VCPKG_ROOT:\$PATH" >> ~/.bashrc
source ~/.bashrc
```

### 安装依赖
```bash
# Install yaml-cpp library
./vcpkg install yaml-cpp
```

## 3. 配置 VS Code/Cursor

### settings.json
```json
{
    "files.associations": {
        "xstring": "cpp",
        "ostream": "cpp"
    },
    "C_Cpp.default.includePath": [
        "${workspaceFolder}/**",
        "${env:HOME}/vcpkg/installed/x64-linux/include"
    ]
}
```

### tasks.json
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "cppbuild",
            "label": "C/C++: g++ build active file",
            "command": "g++",
            "args": [
                "-fdiagnostics-color=always",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}",
                "-I", "${env:HOME}/vcpkg/installed/x64-linux/include",
                "-L", "${env:HOME}/vcpkg/installed/x64-linux/lib",
                "-lyaml-cpp"
            ],
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "detail": "编译器: g++"
        }
    ]
}
```

### launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "C++ Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "C/C++: g++ build active file"
        }
    ]
}
```

## 4. CMake 构建系统配置

创建 `CMakeLists.txt` 文件以支持跨平台构建：

```cmake
cmake_minimum_required(VERSION 3.10)
project(YourProjectName)

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
```

## 5. 验证安装

1. 检查编译器版本：
```bash
g++ --version
```

2. 编译并运行测试程序：
```bash
# 使用 g++ 直接编译
g++ main.cpp -o main && ./main

# 或使用 CMake 构建
mkdir build && cd build
cmake ..
make
./YourProjectName
```

## 注意事项

- 确保所有依赖都已正确安装
- Linux 下路径使用正斜杠 `/`
- 权限问题可以通过 `chmod +x` 解决
- 建议使用 CMake 进行跨平台构建 