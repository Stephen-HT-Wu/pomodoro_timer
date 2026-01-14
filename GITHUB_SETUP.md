# 將專案推送到 GitHub

## 步驟 1：在 GitHub 上創建新倉庫

1. 登入你的 GitHub 帳號
2. 點擊右上角的 "+" 號，選擇 "New repository"
3. 填寫倉庫信息：
   - **Repository name**: `pomodoro_timer` (或你喜歡的名稱)
   - **Description**: `iOS Pomodoro Timer app built with SwiftUI`
   - **Visibility**: 選擇 Public 或 Private
   - **不要**勾選 "Initialize this repository with a README"（因為我們已經有文件了）
4. 點擊 "Create repository"

## 步驟 2：連接到 GitHub 並推送

在終端中執行以下命令（將 `YOUR_USERNAME` 替換為你的 GitHub 用戶名）：

```bash
cd /Users/stephen/pomodoro_timer

# 添加遠程倉庫（替換 YOUR_USERNAME 為你的 GitHub 用戶名）
git remote add origin https://github.com/YOUR_USERNAME/pomodoro_timer.git

# 或者如果你使用 SSH：
# git remote add origin git@github.com:YOUR_USERNAME/pomodoro_timer.git

# 推送代碼到 GitHub
git branch -M main
git push -u origin main
```

## 快速命令（一次性執行）

如果你想一次性完成所有操作，可以使用以下命令：

```bash
cd /Users/stephen/pomodoro_timer
git remote add origin https://github.com/YOUR_USERNAME/pomodoro_timer.git
git branch -M main
git push -u origin main
```

**記得將 `YOUR_USERNAME` 替換為你的實際 GitHub 用戶名！**

## 如果遇到問題

### 認證問題

如果推送時需要認證：

1. **使用 Personal Access Token (推薦)**
   - 前往 GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
   - 生成新 token，勾選 `repo` 權限
   - 推送時使用 token 作為密碼

2. **或使用 SSH**
   - 如果你已設置 SSH keys，使用 SSH URL：
   ```bash
   git remote set-url origin git@github.com:YOUR_USERNAME/pomodoro_timer.git
   git push -u origin main
   ```

### 分支名稱問題

如果默認分支是 `master` 而不是 `main`：

```bash
git branch -M main
git push -u origin main
```

### 如果遠程倉庫已存在 README

如果 GitHub 倉庫已初始化了 README，需要先拉取：

```bash
git pull origin main --allow-unrelated-histories
# 解決可能的衝突後
git push -u origin main
```

## 完成後

推送成功後，你就可以在 GitHub 上看到你的代碼了！

之後如果修改了代碼，使用以下命令更新：

```bash
git add .
git commit -m "描述你的更改"
git push
```
