@echo off

chcp 65001 > nul

setlocal

REM ==============================
REM ■ 1つ以上の引数が必要
REM ==============================
if "%~1"=="" (
    echo "⚠ 結合する分割ファイルを指定してください！"
    
)

REM ==============================
REM ■ PowerShell に全引数を渡して起動
REM ==============================
cd /d %~dp0
powershell -ExecutionPolicy Bypass -File ".\resource\file_join.ps1" %*

endlocal

