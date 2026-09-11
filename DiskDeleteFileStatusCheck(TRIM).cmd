@echo off
chcp 950 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0DiskDeleteFileStatusCheck(TRIM).ps1"
