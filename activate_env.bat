@echo off
setlocal

:: 检测是否在 PowerShell 中运行
set "IS_POWERSHELL="
if defined PSModulePath set "IS_POWERSHELL=1"

:: 创建虚拟环境（如果不存在）
if not exist "%~dp0.venv" (
    echo Creating Python virtual environment...
    python -m venv "%~dp0.venv"
    if errorlevel 1 (
        echo Failed to create virtual environment!
        exit /b 1
    )
)

:: 激活虚拟环境
if defined IS_POWERSHELL (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0.venv\Scripts\Activate.ps1'"
) else (
    call "%~dp0.venv\Scripts\activate.bat"
)
if errorlevel 1 (
    echo Failed to activate virtual environment!
    exit /b 1
)

:: 设置 MSYS2 环境
set "PATH=C:\msys64\mingw64\bin;%PATH%"

:: 验证环境
where g++ >nul 2>&1
if errorlevel 1 (
    echo g++ not found in PATH!
    echo Please ensure MSYS2 is installed and the PATH is set correctly.
    exit /b 1
)

:: 检查并安装 Conan
where conan >nul 2>&1
if errorlevel 1 (
    echo Installing Conan package manager...
    pip install --disable-pip-version-check conan
    if errorlevel 1 (
        echo Failed to install Conan!
        exit /b 1
    )
)

:: 确保 Conan 配置正确
conan profile detect --force

echo Development environment activated successfully!

:: 如果在 PowerShell 中运行，保持环境
if defined IS_POWERSHELL (
    echo To use the environment in PowerShell, run:
    echo .\.venv\Scripts\Activate.ps1
)
