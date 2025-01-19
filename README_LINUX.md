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

## 2. 安装 Conan 包管理器

### 方法 1: 使用系统包管理器（推荐）

```bash
# Debian/Ubuntu
sudo apt install python3-pip python3-venv
sudo apt install conan
```

### 方法 2: 使用 Python 虚拟环境

```bash
# 安装 Python 虚拟环境支持
sudo apt install python3-venv

# 创建虚拟环境
python3 -m venv ~/.conan_env

# 激活虚拟环境
source ~/.conan_env/bin/activate

# 安装 Conan
pip install conan

# 将虚拟环境中的 conan 添加到 PATH（添加到 ~/.bashrc）
echo 'export PATH="$HOME/.conan_env/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 方法 3: 使用 pipx（适用于单个工具安装）

```bash
# 安装 pipx
sudo apt install pipx
pipx ensurepath

# 使用 pipx 安装 conan
pipx install conan
```

## 3. 配置 Conan

```bash
# 验证安装
conan --version

# 添加常用包源
conan remote add conancenter https://center.conan.io

# 检测并创建默认配置
conan profile detect
```

## 4. 项目配置

### conanfile.txt
在项目根目录创建 `conanfile.txt`：

```ini
[requires]
yaml-cpp/0.7.0

[generators]
CMakeDeps
CMakeToolchain

[layout]
cmake_layout
```

### 使用 Conan 安装依赖
```bash
# 创建 build 目录
mkdir build && cd build

# 安装依赖
conan install .. --build=missing
```

## 5. 编译项目

```bash
# 在 build 目录中执行
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build .
```

## 注意事项

- 如果使用虚拟环境，确保在使用 conan 命令前已激活环境
- 首次使用需要配置 Conan profile：`conan profile detect`
- 如果遇到权限问题，可以使用 `chmod +x` 解决
- 建议使用系统包管理器安装方式，避免环境管理问题

## 配置 VS Code/Cursor

### settings.json
```json
{
    "files.associations": {
        "xstring": "cpp",
        "ostream": "cpp"
    },
    "C_Cpp.default.includePath": [
        "${workspaceFolder}/**",
        "${workspaceFolder}/build/generators"
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
                "-I", "${workspaceFolder}/build/generators",
                "-L", "${workspaceFolder}/build/generators",
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

## 验证安装

1. 检查编译器和 Conan 版本：
```bash
g++ --version
conan --version
```

2. 编译并运行测试程序：
```bash
# 使用 CMake 构建
mkdir build && cd build
conan install .. --build=missing
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build .
./CppTemplate
``` 