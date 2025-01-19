@echo off
setlocal EnableDelayedExpansion

:: 激活开发环境
call "%~dp0activate_env.bat"
if errorlevel 1 (
    echo Failed to activate development environment!
    pause
    exit /b 1
)

:: 删除旧的构建目录
if exist build (
    echo Cleaning build directory...
    rmdir /s /q build
    if errorlevel 1 (
        echo Failed to clean build directory!
        pause
        exit /b 1
    )
)

:: 创建新的构建目录
echo Creating build directory...
mkdir build
cd build

:: 安装依赖
echo Installing dependencies...
conan install .. --build=missing -s build_type=Release
if errorlevel 1 (
    echo Failed to install dependencies!
    cd ..
    pause
    exit /b 1
)

:: 配置项目
echo Configuring project...
cmake .. -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=./Release/generators/conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 (
    echo Failed to configure project!
    cd ..
    pause
    exit /b 1
)

:: 构建项目
echo Building project...
cmake --build . --config Release
if errorlevel 1 (
    echo Build failed!
    cd ..
    pause
    exit /b 1
)

cd ..
echo Build completed successfully!
pause
