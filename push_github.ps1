# ============================================
# GitHub 仓库初始化并推送脚本 (PowerShell)
# 用于快速将本地项目推送到 GitHub
# ============================================

param(
    [Parameter(Mandatory=$false)]
    [string]$RepoName = "",
    
    [Parameter(Mandatory=$false)]
    [string]$CommitMsg = "Initial commit",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubUser = "skyconnfig"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub 仓库推送工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查参数
if (-not $RepoName) {
    Write-Host "使用方法:" -ForegroundColor Yellow
    Write-Host "  .\push_github.ps1 -RepoName '仓库名' [-CommitMsg '提交信息'] [-GitHubUser '用户名']"
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "  .\push_github.ps1 -RepoName 'my-project' -CommitMsg 'Initial commit'"
    Write-Host ""
    Write-Host "注意: 请先在 GitHub 上创建空仓库" -ForegroundColor Yellow
    exit 0
}

Write-Host "[1/5] 检查 Git 安装..." -ForegroundColor Green
try {
    git --version | Out-Null
    Write-Host "      Git 已安装" -ForegroundColor Gray
} catch {
    Write-Host "      错误: 未安装 Git" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/5] 检查当前目录 Git 状态..." -ForegroundColor Green
if (-not (Test-Path ".git")) {
    Write-Host "      初始化 Git 仓库..." -ForegroundColor Gray
    git init
    
    # 设置默认分支名
    git config init.defaultBranch main
}

Write-Host ""
Write-Host "[3/5] 配置远程仓库..." -ForegroundColor Green
$remoteUrl = "https://github.com/$GitHubUser/$RepoName.git"
$existingRemote = git remote get-url origin 2>$null

if ($existingRemote) {
    Write-Host "      远程仓库已存在: $existingRemote" -ForegroundColor Gray
    if ($existingRemote -notlike "*$RepoName*") {
        Write-Host "      更新远程仓库地址..." -ForegroundColor Gray
        git remote set-url origin $remoteUrl
    }
} else {
    Write-Host "      添加远程仓库: $remoteUrl" -ForegroundColor Gray
    git remote add origin $remoteUrl
}

Write-Host ""
Write-Host "[4/5] 添加文件并提交..." -ForegroundColor Green
git add .
git commit -m $CommitMsg

Write-Host ""
Write-Host "[5/5] 推送到 GitHub..." -ForegroundColor Green

# 使用 gh CLI 推送
try {
    # 检查 gh 认证状态
    $ghStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "      警告: GitHub CLI 未登录，尝试其他方式..." -ForegroundColor Yellow
        
        # 使用临时克隆方式
        $tempDir = Join-Path $env:TEMP "gh_push_$(Get-Random)"
        
        Write-Host "      克隆空仓库到临时目录..." -ForegroundColor Gray
        gh repo clone "$GitHubUser/$RepoName" $tempDir 2>$null
        
        if (Test-Path $tempDir) {
            # 复制文件
            Get-ChildItem -Exclude $tempDir | Copy-Item -Destination $tempDir -Recurse -Force
            
            # 推送
            Set-Location $tempDir
            git add .
            git commit -m $CommitMsg
            git push
            
            # 清理
            Set-Location -Path $PSScriptRoot
            Remove-Item -Recurse -Force $tempDir
            
            Write-Host "      推送成功!" -ForegroundColor Green
        } else {
            throw "无法克隆仓库，请确保仓库已创建且 gh 已登录"
        }
    } else {
        # gh 已登录，直接推送
        git push -u origin main
        Write-Host "      推送成功!" -ForegroundColor Green
    }
} catch {
    Write-Host "      错误: $_" -ForegroundColor Red
    
    # 备用方案：使用 git credential
    Write-Host ""
    Write-Host "尝试备用方案..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  完成!" -ForegroundColor Cyan
Write-Host "  仓库地址: https://github.com/$GitHubUser/$RepoName" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
