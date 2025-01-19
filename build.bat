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

:: 如果构建成功，暂停显示结果
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful! Press any key to exit...
    pause >nul
) else (
    echo.
    echo Build failed! Press any key to exit...
    pause >nul
)
