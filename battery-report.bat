@echo off
cls
echo.
::Utilizes my report for Chromebook AUE for more detailed information
del /f /q C:\Temp\good-battery.csv
del /f /q C:\Temp\bad-battery.csv
del /f /q "C:\GAMWORK\Chromebook-OS-EOS.csv"
del /f /q "C:\GAMWORK\Chromebook OS EOS.csv"

echo OU,AssetID,Location,Model,Serial,MAC,User,Battery>C:\Temp\bad-battery.csv
echo OU,AssetID,Location,Model,Serial,MAC,User,Battery>C:\Temp\good-battery.csv

gam user fsisd.gam@fsisd.net get drivefile https://docs.google.com/spreadsheets/d/<SheetID>/edit#gid=0 format csv
::File gets copied to GAMWORK folder
ren "C:\GAMWORK\Chromebook OS EOS.csv" Chromebook-OS-EOS.csv
for /f "tokens=1,2,3,4,5,12,16,19 delims=, skip=7" %%a in (C:\GAMWORK\Chromebook-OS-EOS.csv) do call :next "%%a" "%%b" "%%c" "%%d" "%%e" "%%f" "%%g" "%%h"
powershell -Noninteractive -ExecutionPolicy Bypass -file "C:\GAMADV-XTD3\email-bad-battery.ps1"
::pause
exit /b

:next
set ou=%1
set assetid=%2
set location=%3
set model=%4
set sn=%5
set mac=%6
set user=%7
set bat=%8

if %bat% EQU "" goto :EOF
if %bat% NEQ "BATTERY_HEALTH_NORMAL" echo %ou%,%assetid%,%location%,%model%,%sn%,%mac%,%user%,%bat%>>C:\Temp\bad-battery.csv
if %bat% EQU "BATTERY_HEALTH_NORMAL" echo %ou%,%assetid%,%location%,%model%,%sn%,%mac%,%user%,%bat%>>C:\Temp\good-battery.csv
exit /b
