@echo off

:: 列出所有磁碟分割區，包括隱藏的
powershell -command "Get-PhysicalDisk | ForEach-Object { $vols = Get-Partition -DiskNumber $_.DeviceID | Get-Volume; foreach ($v in $vols) { if ($v.DriveLetter) { Write-Output ($v.DriveLetter + ': ' + $_.FriendlyName + ' - ' + $_.MediaType) } else { Write-Output ('[隱藏分割區] ' + $_.FriendlyName + ' - ' + $_.MediaType) } } }"

:: 檢查 TRIM 狀態並判斷刪除檔案後的行為
powershell -command "$trim=(fsutil behavior query DisableDeleteNotify | Out-String); Get-PhysicalDisk | ForEach-Object { $vols = Get-Partition -DiskNumber $_.DeviceID | Get-Volume; foreach ($v in $vols) { $target = if ($v.DriveLetter) { $v.DriveLetter + ':' } else { '[隱藏分割區]' }; if ($_.MediaType -eq 'HDD') { Write-Output ($target + ' HDD → 刪除檔案只移除索引，資料可能殘留，可復原') } elseif ($_.MediaType -eq 'SSD') { if ($trim -match 'DisableDeleteNotify = 0') { Write-Output ($target + ' SSD (TRIM啟用) → 刪除檔案立即釋放區塊，資料不可復原') } else { Write-Output ($target + ' SSD (TRIM未啟用) → 刪除檔案只移除索引，資料可能殘留，可復原') } } else { Write-Output ($target + ' 類型未知') } } }"

pause
