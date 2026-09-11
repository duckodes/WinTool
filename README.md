# WinTool

Windows 常用工具集合，主要以執行 `.cmd` 檔案提供功能。

## 工具

### DiskDeleteFileStatusCheck (TRIM)

檢查電腦的磁碟與分割區資訊，包括：

- SSD / HDD 與 TRIM 狀態
- 分割區大小、可用空間與可用百分比
- NTFS、exFAT、ReFS 等檔案系統
- EFI、Microsoft 保留、基本資料、修復分割區狀態
- 隱藏分割區與磁碟機代號

工具只讀取資訊，不會刪除檔案、格式化磁碟或修改分割區。

## 使用方式

直接雙擊要使用的 `.cmd` 檔案即可。

建議使用 Windows Terminal 或傳統 CMD 執行。按任意鍵即可結束。

## 相容性

- 建議：Windows 10 / 11
- PowerShell：Windows PowerShell 5.1
- 通常需要 Windows 8 / Server 2012 或更新版本的 Storage 模組
- 支援 GPT 與 MBR 磁碟，但不同硬體、RAID、USB 或虛擬磁碟可能回報不同資訊
- Windows 7 或更早版本不保證支援

工具依賴 Windows 內建的 `Get-PhysicalDisk`、`Get-Partition`、`Get-Volume` 與 `fsutil`。

## 注意事項

- 不會有任何上傳等結構指操作指令
- 部分工具使用繁體中文 CMD 編碼，非繁體中文 Windows 可能出現文字或框線顯示差異。
- 某些磁碟資訊可能需要以系統管理員身分執行才能完整讀取。
- 顯示的 TRIM 狀態是 Windows 回報的設定，不代表所有儲存控制器的實際內部行為。

## 專案結構
```text
WinTool/
├─ README.md
├─ DiskDeleteFileStatusCheck(TRIM).cmd
└─ ...更多其他工具.cmd
```
