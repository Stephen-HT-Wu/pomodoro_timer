# 設置指南

## 在 Xcode 中創建專案

### 方法 1：使用 Xcode 創建新專案

1. **打開 Xcode**
   - 啟動 Xcode 應用程式

2. **創建新專案**
   - 選擇 "File" > "New" > "Project"
   - 選擇 "iOS" > "App"
   - 點擊 "Next"

3. **配置專案**
   - **Product Name**: `PomodoroTimer`
   - **Team**: 選擇你的開發團隊（如果需要）
   - **Organization Identifier**: 例如 `com.yourname`
   - **Interface**: 選擇 **SwiftUI**
   - **Language**: 選擇 **Swift**
   - **Storage**: 選擇 "None"（我們不需要 Core Data）
   - 點擊 "Next"

4. **選擇保存位置**
   - 選擇一個位置保存專案
   - **不要勾選** "Create Git repository"（如果已經有 git）
   - 點擊 "Create"

5. **替換文件**
   - 刪除 Xcode 自動生成的 `ContentView.swift` 和 `PomodoroTimerApp.swift`
   - 將本目錄中的所有 `.swift` 文件複製到專案中
   - 將 `Info.plist` 複製到專案中（如果需要）

6. **添加文件到專案**
   - 在 Xcode 中，右鍵點擊專案導航器
   - 選擇 "Add Files to [專案名]"
   - 選擇所有 `.swift` 文件
   - 確保 "Copy items if needed" 已勾選
   - 點擊 "Add"

### 方法 2：使用命令行工具

如果你熟悉命令行，可以使用以下步驟：

```bash
# 創建 Xcode 專案（需要安裝 xcodegen 或手動創建）
# 或者直接在 Xcode 中創建專案後複製文件
```

## 運行應用

1. **選擇目標設備**
   - 在 Xcode 頂部工具欄中選擇模擬器或連接的真實設備
   - 推薦使用 iPhone 14 或更新的模擬器

2. **運行**
   - 點擊運行按鈕（⌘R）或選擇 "Product" > "Run"
   - 應用將在選定的設備上啟動

## 測試功能

- ✅ 點擊播放按鈕開始計時
- ✅ 點擊暫停按鈕暫停計時
- ✅ 點擊重置按鈕重置計時器
- ✅ 點擊跳過按鈕跳過當前階段
- ✅ 觀察進度條和時間倒數
- ✅ 完成一個 Pomodoro 後自動進入休息時間
- ✅ 完成 4 個 Pomodoro 後進入長休息

## 故障排除

### 編譯錯誤

如果遇到編譯錯誤：

1. **清理構建文件夾**
   - 選擇 "Product" > "Clean Build Folder" (⇧⌘K)

2. **檢查 Swift 版本**
   - 確保使用 Swift 5.0 或更高版本

3. **檢查部署目標**
   - 在專案設置中，確保 "iOS Deployment Target" 設為 iOS 14.0 或更高

### 運行時問題

如果應用無法運行：

1. **檢查簽名**
   - 在 "Signing & Capabilities" 中選擇你的開發團隊

2. **檢查設備兼容性**
   - 確保目標設備支持 iOS 14.0 或更高版本

## 下一步

應用已經可以正常運行！你可以：

- 自定義顏色和樣式
- 添加通知功能
- 添加音效
- 添加統計數據追蹤
- 優化 UI 設計

享受你的 Pomodoro Timer！
