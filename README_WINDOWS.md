# Windows C++ 开发环境配置指南

本指南介绍如何在 Windows 系统上配置 C++ 开发环境，使用 MinGW-w64 作为编译工具链和 Conan 作为包管理器。

## 1. 配置 PowerShell 执行策略

在使用虚拟环境之前，需要先配置 PowerShell 的执行策略。以管理员身份运行 PowerShell，然后执行以下命令：

```powershell
# 查看当前执行策略
Get-ExecutionPolicy

# 设置执行策略为 RemoteSigned（推荐）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或者设置为 Bypass（不推荐，仅用于测试）
# Set-ExecutionPolicy Bypass -Scope CurrentUser
```

## 2. 安装 MSYS2

1. 访问 [MSYS2 官网](https://www.msys2.org/) 下载安装程序
2. 运行安装程序，建议安装到默认位置 `C:\msys64`
3. 打开 "MSYS2 MINGW64" 终端，运行以下命令更新系统：
```bash
pacman -Syu
```

## 3. 安装编译工具

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

## 4. 配置环境变量

1. 按 Win + R，输入 sysdm.cpl
2. 点击"高级" -> "环境变量"
3. 在"系统变量"的 Path 中添加：
   - `C:\msys64\mingw64\bin`
4. 点击"确定"保存

## 5. 安装 Conan 包管理器

### 方法 1：使用 Python 虚拟环境（推荐）

在 MSYS2 MINGW64 终端中运行：
```bash
# 创建项目目录（如果还没有）
mkdir -p ~/cpp-dev
cd ~/cpp-dev

# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
source .venv/bin/activate   # 在 MSYS2 MINGW64 中使用
# 或在 CMD 中使用：
# .venv\Scripts\activate.bat
# 或在 PowerShell 中使用：
# .venv\Scripts\Activate.ps1

# 安装 Conan
pip install conan

# 验证安装
conan --version

# 添加包源
conan remote add conancenter https://center.conan.io

# 创建默认配置文件
conan profile detect --force
```

### 方法 2：使用系统全局安装

```bash
# 安装 Conan
pip install conan

# 验证安装
conan --version

# 添加包源
conan remote add conancenter https://center.conan.io
```

## 6. 配置构建环境

创建 `activate_env.bat` 文件用于激活开发环境：
```batch
@echo off
:: 激活 Python 虚拟环境
if exist "%~dp0.venv\Scripts\activate.bat" (
    call "%~dp0.venv\Scripts\activate.bat"
) else (
    echo Python virtual environment not found!
    exit /b 1
)

:: 设置 MSYS2 环境
set PATH=C:\msys64\mingw64\bin;%PATH%

:: 验证环境
where g++ >nul 2>&1
if errorlevel 1 (
    echo g++ not found in PATH!
    exit /b 1
)

where conan >nul 2>&1
if errorlevel 1 (
    echo conan not found in PATH!
    exit /b 1
)

echo Development environment activated successfully!
```

## 7. 更新构建脚本

修改 `build.bat` 以使用虚拟环境：
```batch
@echo off
setlocal

:: 激活开发环境
call activate_env.bat
if errorlevel 1 (
    echo Failed to activate development environment!
    exit /b 1
)

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

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful! Press any key to exit...
    pause >nul
) else (
    echo.
    echo Build failed! Press any key to exit...
    pause >nul
)
```

## 8. 配置 VS Code

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

## 9. 项目构建

### 方法 1：使用命令行

创建 `build.bat` 文件：
```batch
@echo off
setlocal

:: 激活开发环境
call activate_env.bat
if errorlevel 1 (
    echo Failed to activate development environment!
    exit /b 1
)

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

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful! Press any key to exit...
    pause >nul
) else (
    echo.
    echo Build failed! Press any key to exit...
    pause >nul
)
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

## 10. 验证安装

1. 检查工具链：
```
