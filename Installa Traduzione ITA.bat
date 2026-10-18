@echo off
setlocal
chcp 65001 >nul
title Aniimo - Traduzione Italiana

if not exist "%~dp0dati\installer.ps1" (
    echo.
    echo  [ERRORE] File "dati\installer.ps1" non trovato!
    echo  Assicurati di aver estratto TUTTO l'archivio ZIP in una cartella
    echo  prima di avviare questo programma ^(non avviarlo da dentro lo ZIP^).
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Sta -File "%~dp0dati\installer.ps1" %*
endlocal
