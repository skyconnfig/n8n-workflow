#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GitHub 仓库推送工具
快速将本地项目推送到 GitHub

使用方法:
    python push_github.py 仓库名 "提交信息"

示例:
    python push_github.py my-project "Initial commit"
"""

import os
import sys
import subprocess
import tempfile
import shutil
from pathlib import Path

# ============ 配置区域 ============
GITHUB_USER = "skyconnfig"
# =================================

def run_cmd(cmd, cwd=None, capture=True):
    """执行命令"""
    try:
        result = subprocess.run(
            cmd, 
            shell=True, 
            cwd=cwd, 
            capture_output=capture, 
            text=True,
            encoding='utf-8'
        )
        return result.returncode, result.stdout, result.stderr
    except Exception as e:
        return 1, "", str(e)

def check_gh_auth():
    """检查 GitHub CLI 认证"""
    code, stdout, stderr = run_cmd("gh auth status")
    if code == 0:
        print("      ✓ GitHub CLI 已登录")
        return True
    else:
        print("      ✗ GitHub CLI 未登录或认证失败")
        return False

def init_git():
    """初始化 Git 仓库"""
    if not os.path.exists(".git"):
        print("      初始化 Git 仓库...")
        run_cmd("git init")
        run_cmd('git config init.defaultBranch main')
        return False
    else:
        print("      Git 仓库已存在")
        return True

def setup_remote(repo_name):
    """配置远程仓库"""
    remote_url = f"https://github.com/{GITHUB_USER}/{repo_name}.git"
    
    code, stdout, _ = run_cmd("git remote get-url origin")
    
    if code == 0:
        if repo_name in stdout:
            print(f"      远程仓库已配置: {stdout.strip()}")
        else:
            print(f"      更新远程仓库: {remote_url}")
            run_cmd(f'git remote set-url origin {remote_url}')
    else:
        print(f"      添加远程仓库: {remote_url}")
        run_cmd(f'git remote add origin {remote_url}')

def commit_files(commit_msg):
    """提交文件"""
    print("      添加文件到暂存区...")
    run_cmd("git add .")
    
    print(f"      提交: {commit_msg}")
    code, stdout, stderr = run_cmd(f'git commit -m "{commit_msg}"')
    
    if "nothing to commit" in stdout or code == 0:
        return True
    return False

def push_to_github(repo_name, commit_msg):
    """推送到 GitHub"""
    print("      尝试推送到 GitHub...")
    
    # 方法1: 直接推送 (gh 已登录时)
    code, stdout, stderr = run_cmd("git push -u origin main")
    
    if code == 0:
        print("      ✓ 直接推送成功!")
        return True
    
    # 方法2: 使用 gh repo clone 技巧
    print("      尝试备用方法...")
    
    temp_dir = os.path.join(tempfile.gettempdir(), f"gh_push_{repo_name}_{os.getpid()}")
    
    # 删除已存在目录
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    
    # 克隆空仓库
    code, stdout, stderr = run_cmd(f"gh repo clone {GITHUB_USER}/{repo_name} \"{temp_dir}\"")
    
    if code != 0:
        print(f"      ✗ 克隆失败: {stderr}")
        return False
    
    try:
        # 复制文件到克隆的仓库
        print("      复制文件到仓库...")
        
        # 获取当前目录所有文件
        for item in os.listdir("."):
            if item in [".git", temp_dir, os.path.basename(__file__)]:
                continue
            src = os.path.join(".", item)
            dst = os.path.join(temp_dir, item)
            
            if os.path.isdir(src):
                if os.path.exists(dst):
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
            else:
                shutil.copy2(src, dst)
        
        # 提交并推送
        print("      提交更改...")
        run_cmd("git add .", cwd=temp_dir)
        run_cmd(f'git commit -m "{commit_msg}"', cwd=temp_dir)
        
        print("      推送到远程...")
        code, stdout, stderr = run_cmd("git push", cwd=temp_dir)
        
        if code == 0:
            print("      ✓ 推送成功!")
            return True
        else:
            print(f"      ✗ 推送失败: {stderr}")
            return False
            
    finally:
        # 清理临时目录
        if os.path.exists(temp_dir):
            try:
                os.chdir(".")  # 确保不在临时目录
                shutil.rmtree(temp_dir)
            except:
                pass
    
    return False

def main():
    print()
    print("=" * 40)
    print("  GitHub 仓库推送工具")
    print("=" * 40)
    print()
    
    # 检查参数
    if len(sys.argv) < 2:
        repo_name = input("请输入仓库名: ").strip()
        commit_msg = input("请输入提交信息 (默认: Initial commit): ").strip()
        if not commit_msg:
            commit_msg = "Initial commit"
    else:
        repo_name = sys.argv[1]
        commit_msg = sys.argv[2] if len(sys.argv) > 2 else "Initial commit"
    
    if not repo_name:
        print("错误: 仓库名不能为空")
        sys.exit(1)
    
    print(f"[1/4] 初始化 Git 仓库...")
    init_git()
    
    print(f"\n[2/4] 配置远程仓库...")
    setup_remote(repo_name)
    
    print(f"\n[3/4] 提交文件...")
    has_changes = commit_files(commit_msg)
    if not has_changes:
        print("      没有新文件需要提交")
    
    print(f"\n[4/4] 推送到 GitHub...")
    success = push_to_github(repo_name, commit_msg)
    
    print()
    print("=" * 40)
    if success:
        print(f"  ✓ 推送成功!")
        print(f"  仓库地址: https://github.com/{GITHUB_USER}/{repo_name}")
    else:
        print(f"  ✗ 推送失败，请检查错误信息")
    print("=" * 40)
    print()

if __name__ == "__main__":
    main()
