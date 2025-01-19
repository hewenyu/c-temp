# Windows C++ 开发环境配置指南

本指南介绍如何在 Windows 系统上配置 C++ 开发环境，使用 MSYS2/MinGW-w64 作为编译工具链。

## 1. 安装 MSYS2

1. 访问 [MSYS2 官网](https://www.msys2.org/) 下载安装程序
2. 运行安装程序，建议安装到默认位置 `C:\msys64`

## 2. 安装编译工具

1. 打开 "MSYS2 MINGW64" 终端（在开始菜单中搜索）
2. 运行以下命令更新系统并安装必要工具：
```bash
pacman -Syu
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gdb
```

## 3.安装vcpkg


### 下载

```bash
# Clone vcpkg repository
git clone https://github.com/Microsoft/vcpkg.git

# Run the bootstrap script
.\vcpkg\bootstrap-vcpkg.bat
```

### 依赖

```bash
# Install yaml-cpp library
vcpkg install yaml-cpp:x64-windows
```



## 3. 配置环境变量

1. 按 Win + R，输入 sysdm.cpl
2. 点击"高级" -> "环境变量"
3. 在"系统变量"的 Path 中添加：
    - `C:\msys64\mingw64\bin`
    - `C:\Users\[YourUsername]\code\microsoft\vcpkg\installed\x64-windows\bin`
4. 点击"确定"保存

## 4. 配置 VS Code

### settings.json
```json
{
    "files.associations": {
        "xstring": "cpp",
        "ostream": "cpp"
    },
    "C_Cpp.default.includePath": [
        "${workspaceFolder}/**",
        "C:/Users/[YourUsername]/code/microsoft/vcpkg/installed/x64-windows/include"
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
            "command": "g++.exe",
            "args": [
                "-fdiagnostics-color=always",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}\\${fileBasenameNoExtension}.exe",
                "-I", "C:/Users/[YourUsername]/code/microsoft/vcpkg/installed/x64-windows/include",
                "-L", "C:/Users/[YourUsername]/code/microsoft/vcpkg/installed/x64-windows/lib",
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
            "preLaunchTask": "C/C++: g++ build active file"
        }
    ]
}
```

## 5. 验证安装

1. 打开新的终端，运行：
```bash
g++ --version
```
应该显示版本信息

2. 在编辑器中创建并运行一个简单的 C++ 程序：
```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

## 注意事项

- 如果命令提示符找不到 g++，请确保重新打开终端
- 确保所有配置文件中的路径使用双反斜杠 `\\`
- 如果使用 Cursor 编辑器，配置过程与 VS Code 相同

# C++ 项目模板

这是一个现代 C++ 项目模板，使用 CMake 构建系统和 Conan 包管理器。

## 开发环境设置

### 必需工具

- C++ 编译器 (GCC/Clang)
- CMake (>= 3.15)
- Python 3.x (用于 Conan)
- Git

### VS Code 配置

本项目已预配置了 VS Code 开发环境。请安装以下推荐的插件：

1. **必需插件**:
   - `ms-vscode.cpptools`: C/C++ 语言支持
   - `ms-vscode.cmake-tools`: CMake 集成
   - `twxs.cmake`: CMake 语言支持
   - `xaver.clang-format`: 代码格式化

2. **推荐插件**:
   - `cschlosser.doxdocgen`: 文档生成
   - `eamodio.gitlens`: Git 增强
   - `ms-vscode.cpptools-extension-pack`: C++ 扩展包

VS Code 会自动提示安装这些推荐的插件。

### 编辑器功能

项目已配置以下 VS Code 功能：

- 代码自动格式化（保存时）
- CMake 集成
- 智能代码补全
- 代码导航
- 调试支持

## 构建说明

### Windows
请参考 `README_WINDOWS.md`

### Linux
请参考 `README_LINUX.md`

## 项目结构

```
.
├── .vscode/          # VS Code 配置
├── build/            # 构建输出目录
├── src/             # 源代码
├── include/         # 头文件
├── tests/           # 测试文件
├── CMakeLists.txt   # CMake 构建配置
├── conanfile.txt    # Conan 依赖配置
└── build.sh         # 构建脚本
```

## 开发流程

1. 克隆项目:
```bash
git clone <repository-url>
cd <project-name>
```

2. 安装依赖:
```bash
# 确保在项目根目录
./build.sh
```

3. 在 VS Code 中开发:
- 使用 CMake 工具栏进行构建/调试
- 按 F5 启动调试
- Ctrl+Shift+B 构建项目

## 编码规范

- 使用 C++17 标准
- 遵循现代 C++ 实践
- 使用 clang-format 进行代码格式化
- 代码行长度限制：120 字符
- 使用 4 空格缩进

## 依赖管理

项目使用 Conan 管理依赖，主要依赖包：
- yaml-cpp: YAML 解析库

添加新依赖：
1. 在 `conanfile.txt` 中添加依赖
2. 运行 `./build.sh` 更新依赖
