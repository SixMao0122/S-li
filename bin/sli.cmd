@echo off
rem S-li Entrypoint for CMD / Terminal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sli.ps1" %*
