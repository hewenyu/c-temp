# Windows C++ 开发环境配置指南

本指南介绍如何在 Windows 系统上配置 C++ 开发环境，使用 MinGW-w64 作为编译工具链和 Conan 作为包管理器。

## 1. 安装 MSYS2

1. 访问 [MSYS2 官网](https://www.msys2.org/) 下载安装程序
2. 运行安装程序，建议安装到默认位置 `C:\msys64`
3. 打开 "MSYS2 MINGW64" 终端，运行以下命令更新系统：
```bash
pacman -Syu
```

## 2. 安装编译工具

在 MSYS2 MINGW64 终端中运行：
```bash
# 安装基本开发工具
pacman -S mingw-w64-x86_64-gcc
pacman -S mingw-w64-x86_64-gdb
pacman -S mingw-w64-x86_64-cmake
pacman -S mingw-w64-x86_64-make
pacman -S mingw-w64-x86_64-python
pacman -S mingw-w64-x86_64-python-pip
```

## 3. 配置环境变量

1. 按 Win + R，输入 sysdm.cpl
2. 点击"高级" -> "环境变量"
3. 在"系统变量"的 Path 中添加：
   - `C:\msys64\mingw64\bin`
4. 点击"确定"保存

## 4. 安装 Conan 包管理器

在 MSYS2 MINGW64 终端中运行：
```bash
# 安装 Conan
pip install conan

# 验证安装
conan --version

# 添加包源
conan remote add conancenter https://center.conan.io

# 创建默认配置文件
conan profile detect --force
```

## 5. 配置 VS Code

### 必需插件

1. C/C++ 开发必需插件：
   - C/C++ (`ms-vscode.cpptools`)
   - CMake Tools (`ms-vscode.cmake-tools`)
   - CMake (`twxs.cmake`)
   - Clang-Format (`xaver.clang-format`)

2. 推荐插件：
   - C/C++ Extension Pack (`ms-vscode.cpptools-extension-pack`)
   - GitLens (`eamodio.gitlens`)
   - Doxygen Documentation Generator (`cschlosser.doxdocgen`)

VS Code 会自动提示安装这些推荐的插件。

### VS Code 配置文件

#### settings.json
```json
{
    "files.associations": {
        "*.h": "cpp",
        "*.hpp": "cpp",
        "*.cpp": "cpp",
        "*.inl": "cpp"
    },
    "C_Cpp.default.includePath": [
        "${workspaceFolder}/**",
        "${workspaceFolder}/build/Release/generators"
    ],
    "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools",
    "C_Cpp.default.cppStandard": "c++17",
    "cmake.configureOnOpen": true,
    "cmake.buildDirectory": "${workspaceFolder}/build",
    "cmake.generator": "MinGW Makefiles",
    "editor.formatOnSave": true
}
```

#### tasks.json
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "cppbuild",
            "label": "C/C++: g++.exe build active file",
            "command": "g++.exe",
            "args": [
                "-fdiagnostics-color=always",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}\\${fileBasenameNoExtension}.exe",
                "-I", "${workspaceFolder}/build/Release/generators",
                "-L", "${workspaceFolder}/build/Release/generators",
                "-lyaml-cpp"
            ],
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": ["$gcc"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "detail": "编译器: g++.exe"
        }
    ]
}
```

#### launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "C++ Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}\\${fileBasenameNoExtension}.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "C:\\msys64\\mingw64\\bin\\gdb.exe",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "C/C++: g++.exe build active file"
        }
    ]
}
```

## 6. 项目构建

### 方法 1：使用命令行

创建 `build.bat` 文件：
```batch
@echo off
setlocal

:: 删除旧的构建目录
if exist build rmdir /s /q build

:: 创建新的构建目录
mkdir build
cd build

:: 确保 Conan profile 存在
conan profile detect --force

:: 安装依赖
conan install .. --build=missing -s build_type=Release

:: 配置项目
cmake .. -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=./Release/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release

:: 构建项目
cmake --build . --config Release

echo Build completed successfully!
```

运行构建：
```bash
.\build.bat
```

### 方法 2：使用 VS Code

1. 打开命令面板 (Ctrl+Shift+P)
2. 输入 "CMake: Configure"
3. 选择 "MinGW Makefiles" 作为生成器
4. 等待配置完成
5. 点击底部状态栏的 "Build" 按钮或使用 F7 快捷键

## 7. 验证安装

1. 检查工具链：
```bash
g++ --version
cmake --version
conan --version
```

2. 编译并运行测试程序：
```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

## 注意事项

1. **路径问题**：
   - Windows 路径中使用反斜杠 `\`
   - CMake 配置中路径可以使用正斜杠 `/`
   - 避免路径中包含空格和特殊字符

2. **编译器问题**：
   - 确保使用 MSYS2 MINGW64 的 g++
   - 不要混用不同版本的编译器

3. **依赖管理**：
   - 使用 Conan 管理第三方库
   - 保持 conanfile.txt 更新
   - 运行 build.bat 时会自动安装依赖

4. **VS Code 配置**：
   - 首次打开项目时允许 CMake 配置
   - 如果更改了依赖，需要重新配置 CMake
   - 使用 CMake Tools 扩展管理构建
