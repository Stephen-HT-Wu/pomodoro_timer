# 在 MacBook 上運行 Pomodoro Timer

## 步驟 1：安裝 Xcode

如果你還沒有安裝 Xcode：

1. **從 App Store 安裝（推薦）**
   - 打開 App Store
   - 搜索 "Xcode"
   - 點擊 "取得" 或 "安裝"
   - 等待下載完成（約 10-15 GB，需要一些時間）

2. **或從 Apple Developer 網站下載**
   - 前往 https://developer.apple.com/xcode/
   - 下載最新版本

3. **安裝後設置**
   - 打開 Xcode（首次打開需要一些時間來安裝組件）
   - 接受許可協議
   - 安裝額外組件（會自動提示）

## 步驟 2：創建 Xcode 專案

### 方法 A：使用 Xcode GUI（推薦）

1. **打開 Xcode**
   - 從 Applications 文件夾或 Launchpad 打開 Xcode

2. **創建新專案**
   - 選擇 "File" > "New" > "Project"（或按 `⇧⌘N`）
   - 在彈出窗口中：
     - 選擇 **iOS** 標籤
     - 選擇 **App** 模板
     - 點擊 "Next"

3. **配置專案信息**
   - **Product Name**: `PomodoroTimer`
   - **Team**: 選擇你的 Apple ID（如果沒有，點擊 "Add Account..." 添加）
   - **Organization Identifier**: 例如 `com.yourname` 或 `com.yourcompany`
   - **Interface**: 選擇 **SwiftUI** ⚠️ 重要！
   - **Language**: 選擇 **Swift**
   - **Storage**: 選擇 "None"
   - 點擊 "Next"

4. **選擇保存位置**
   - **不要**選擇當前 `pomodoro_timer` 文件夾
   - 選擇一個新位置，例如 `~/Desktop/PomodoroTimer` 或 `~/Documents/PomodoroTimer`
   - 取消勾選 "Create Git repository"（因為我們已經有 git 了）
   - 點擊 "Create"

5. **替換自動生成的文件**
   - 在 Xcode 左側的專案導航器中，找到並**刪除**以下文件：
     - `PomodoroTimerApp.swift`（如果存在）
     - `ContentView.swift`
   - 右鍵點擊專案名稱，選擇 "Add Files to PomodoroTimer..."
   - 導航到 `/Users/stephen/pomodoro_timer/` 文件夾
   - 選擇以下文件：
     - `PomodoroTimerApp.swift`
     - `PomodoroTimer.swift`
     - `ContentView.swift`
   - 確保勾選 "Copy items if needed"
   - 確保 "Add to targets: PomodoroTimer" 已勾選
   - 點擊 "Add"

### 方法 B：使用命令行（進階）

如果你熟悉命令行，可以使用：

```bash
# 創建新的 Xcode 專案（需要手動配置）
# 建議還是使用 GUI 方法
```

## 步驟 3：運行應用

1. **選擇運行目標**
   - 在 Xcode 頂部工具欄，點擊設備選擇器
   - 選擇：
     - **iPhone 模擬器**（推薦，例如 "iPhone 15" 或 "iPhone 15 Pro"）
     - 或連接的真實 iPhone/iPad

2. **運行應用**
   - 點擊左上角的播放按鈕 ▶️
   - 或按快捷鍵 `⌘R`
   - 或選擇 "Product" > "Run"

3. **等待編譯和啟動**
   - Xcode 會先編譯專案（第一次可能需要一些時間）
   - 編譯成功後，模擬器會自動啟動
   - 應用會自動安裝並運行在模擬器上

## 步驟 4：測試功能

應用運行後，你可以測試：

- ✅ 點擊中央的播放按鈕開始計時
- ✅ 觀察圓形進度條和倒數計時
- ✅ 點擊暫停按鈕暫停
- ✅ 點擊重置按鈕重置
- ✅ 點擊跳過按鈕跳過當前階段
- ✅ 完成一個 Pomodoro 後自動進入休息

## 常見問題

### 問題 1：編譯錯誤

**解決方法：**
- 選擇 "Product" > "Clean Build Folder"（或按 `⇧⌘K`）
- 重新運行

### 問題 2：找不到模擬器

**解決方法：**
- 選擇 "Xcode" > "Settings" > "Platforms"
- 下載 iOS 模擬器

### 問題 3：簽名錯誤

**解決方法：**
- 在專案導航器中選擇專案名稱
- 選擇 "Signing & Capabilities" 標籤
- 在 "Team" 下拉菜單中選擇你的 Apple ID
- 如果沒有，點擊 "Add Account..." 添加

### 問題 4：Swift 版本錯誤

**解決方法：**
- 確保 Xcode 版本是 12.0 或更高
- 檢查 "Build Settings" > "Swift Language Version" 設為 Swift 5

## 快捷鍵

- `⌘R` - 運行應用
- `⌘.` - 停止運行
- `⇧⌘K` - 清理構建文件夾
- `⌘B` - 僅編譯（不運行）

## 下一步

應用成功運行後，你可以：

- 修改顏色和樣式
- 添加新功能
- 在真實設備上測試
- 準備發布到 App Store

享受你的 Pomodoro Timer！🍅
