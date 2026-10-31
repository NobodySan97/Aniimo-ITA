@echo off
setlocal
chcp 65001 >nul
title Aniimo - Traduzione Italiana

rem Riavvio minimalizzato: evita il flash della finestra console all'avvio.
rem Se il file installer.ps1 manca, non riavvia e mostra l'errore in finestra visibile.
if not "%~1"=="_hidden_" (
    if exist "%~dp0dati\installer.ps1" (
        start "Aniimo ITA" /MIN cmd /c ""%~f0" _hidden_ %*"
        exit /b 0
    )
)

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
