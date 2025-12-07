@echo off

chcp 65001 > nul

setlocal

REM ==============================
REM ■ 1つの引数が必要
REM ==============================
set INPUT_FILE=%1

if "%INPUT_FILE%"=="" (
    echo "⚠ 引数として入力ファイルを指定してください！"
    pause
)

REM ==============================
REM ■ PowerShell に引数を渡して起動
REM ==============================
cd /d %~dp0
powershell -ExecutionPolicy Bypass -File ".\resource\file_split.ps1" -inputFile "%INPUT_FILE%"

endlocal
