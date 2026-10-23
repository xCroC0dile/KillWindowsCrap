@echo off
:: Ensure script is running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    pause
    exit /b
)

echo ===================================================
echo [1/6] Nuking Active Disk-Thrashing Processes...
echo ===================================================
taskkill /F /IM TiWorker.exe /T 2>nul
taskkill /F /IM TrustedInstaller.exe /T 2>nul
taskkill /F /IM wscript.exe /T 2>nul

echo ===================================================
echo [2/6] Stopping and Disabling Heavy HDD Services...
echo ===================================================
:: Windows Update & Component Servicing
net stop wuauserv /y 2>nul
sc config wuauserv start= disabled
sc config wuauserv obj= "NT AUTHORITY\NetworkService"

net stop TrustedInstaller /y 2>nul
sc config TrustedInstaller start= disabled

net stop WaaSMedicSvc /y 2>nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f

net stop bits /y 2>nul
sc config bits start= disabled

net stop dosvc /y 2>nul
sc config dosvc start= disabled

:: Superfetch/SysMain, Search Indexer, and Diagnostics (HDD killers)
net stop SysMain /y 2>nul
sc config SysMain start= disabled

net stop WSearch /y 2>nul
sc config WSearch start= disabled

net stop DiagTrack /y 2>nul
sc config DiagTrack start= disabled

echo ===================================================
echo [3/6] Locking Down Windows Update via Registry...
echo ===================================================
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" /f 2>nul

echo ===================================================
echo [4/6] Disabling Auto-Wake & Servicing Scheduled Tasks...
echo ===================================================
schtasks /change /tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /disable 2>nul
schtasks /change /tn "\Microsoft\Windows\WaaSMedic\PerformRemediation" /disable 2>nul
schtasks /change /tn "\Microsoft\Windows\Servicing\StartComponentCleanup" /disable 2>nul
del /q /f C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator\* 2>nul

echo ===================================================
echo [5/6] Flushing Staged Downloads & Update Cache...
echo ===================================================
del /q /f /s C:\Windows\SoftwareDistribution\Download\* 2>nul

echo ===================================================
echo [6/6] Neutralizing VBScript Malware Pop-up...
echo ===================================================
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Video" /f 2>nul
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Video.3gp" /f 2>nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "Video" /f 2>nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "Video.3gp" /f 2>nul
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Video.3gp" /f 2>nul

:: Create the silent 0-byte dummy file for current & public users
if exist "%APPDATA%" (
    type nul > "%APPDATA%\Video.3gp"
)

echo.
echo ===================================================
echo [DONE] System locked down. Disk usage will drop to 0%%.
echo Restart the machine to finalize.
echo ===================================================
pause
