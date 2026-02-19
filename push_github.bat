@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================
:: GitHub 仓库初始化并推送脚本
:: 用于快速将本地项目推送到 GitHub
:: ============================================

echo.
echo ========================================
echo   GitHub 仓库推送工具
echo ========================================
echo.

:: 检查参数
if "%~1"=="" (
    echo 使用方法:
    echo   push_github.bat [仓库名] [提交信息]
    echo.
    echo 示例:
    echo   push_github.bat my-project "Initial commit"
    echo.
    echo 注意: 请先在 GitHub 上创建空仓库
    echo.
    goto :end
)

set REPO_NAME=%~1
set COMMIT_MSG=%~2
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Initial commit

echo [1/4] 检查当前目录 Git 状态...
if not exist ".git" (
    echo     初始化 Git 仓库...
    git init
)

echo.
echo [2/4] 添加远程仓库...
git remote add origin https://github.com/skyconnfig/%REPO_NAME%.git 2>nul
if errorlevel 1 (
    echo     远程仓库已存在，跳过...
)

echo.
echo [3/4] 添加文件并提交...
git add .
git commit -m "%COMMIT_MSG%"

echo.
echo [4/4] 推送到 GitHub...
:: 使用 gh repo clone 的技巧来推送（避免凭证问题）
set TEMP_REPO=%TEMP%\gh_push_temp_%RANDOM%
gh repo clone skyconnfig/%REPO_NAME% "%TEMP_REPO%" -- --depth=1 2>nul

if exist "%TEMP_REPO%" (
    xcopy /E /Q /Y * "%TEMP_REPO%\" >nul
    cd /d "%TEMP_REPO%"
    git add .
    git commit -m "%COMMIT_MSG%"
    git push
    cd /d %~dp0
    rd /s /q "%TEMP_REPO%"
    echo.
    echo ========================================
    echo   推送成功!
    echo   仓库地址: https://github.com/skyconnfig/%REPO_NAME%
    echo ========================================
) else (
    echo.
    echo 错误: 无法访问远程仓库，请检查:
    echo   1. 仓库是否已创建
    echo   2. gh auth 登录状态
    echo.
)

:end
echo.
pause
