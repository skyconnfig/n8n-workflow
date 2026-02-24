# GitHub Push Scripts - 使用说明

## 快速开始

### 方式一：Python 脚本（推荐）

```bash
# 基本用法
python push_github.py 仓库名 "提交信息"

# 示例
python push_github.py my-project "Initial commit"
python push_github.py n8n-workflow "Add new feature"
```

### 方式二：PowerShell 脚本

```powershell
# 基本用法
.\push_github.ps1 -RepoName "仓库名" -CommitMsg "提交信息"

# 示例
.\push_github.ps1 -RepoName "my-project" -CommitMsg "Initial commit"
.\push_github.ps1 -RepoName "n8n-workflow" -CommitMsg "Add new feature"
```

### 方式三：Batch 脚本

```cmd
push_github.bat 仓库名 "提交信息"

# 示例
push_github.bat my-project "Initial commit"
```

## 配置

在 `push_github.py` 中修改默认 GitHub 用户名：

```python
GITHUB_USER = "skyconnfig"  # 修改为你的用户名
```

## 使用流程

1. **先在 GitHub 上创建空仓库**（必须先创建）
2. **运行脚本**：
   - Python: `python push_github.py 仓库名`
   - PowerShell: `.\push_github.ps1 -RepoName 仓库名`
   - Batch: `push_github.bat 仓库名`
3. **脚本会自动**：
   - 初始化 Git（如果未初始化）
   - 添加远程仓库
   - 提交所有文件
   - 推送到 GitHub

## 注意事项

- 请确保先在 GitHub 上创建空仓库
- 首次使用需要登录 GitHub CLI (`gh auth login`)
- 脚本会自动处理凭证问题
