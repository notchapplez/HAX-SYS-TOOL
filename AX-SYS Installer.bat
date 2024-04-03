@echo off
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

echo ///// Version 1.0
echo ////
echo ///        AX-SYS Tool
echo //
echo / Made by FerrousInk

:start
if exist "%programfiles% (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" echo [ + ] SDKs Installed!
if exist "%programfiles% (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" goto after-sdk
if not exist "%programfiles% (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" goto :sdk-not-installed

:sdk-not-installed
echo [ - ] Windows 10 ADK; Win-ADK-Pe-Addon Not Installed!
:ask-again-sdk-install
set /p sdk-install=[ - ] Install them? [Y/N] :
if y == %sdk-install% (goto install-sdks) else (if Y == %sdk-install% (goto install-sdks) else (if n == %sdk-install% (goto after-sdk) else (if N == %sdk-install% (goto after-sdk) else (goto ask-again-sdk-install))))

:rufus-not-installed
echo [ - ] Rufus Not Installed!
:ask-again-rufus-install
set /p rufus-install=[ - ] Install Rufus? (Rufus is only needed for flashing a usb) [Y/N] :
if y == %rufus-install% (goto install-rufus) else (if Y == %rufus-install% (goto install-rufus) else (if n == %rufus-install% (goto after-rufus) else (if N == %rufus-install% (goto after-rufus) else (goto ask-again-rufus-install))))


rem Installs

:install-sdks
winget install Microsoft.WindowsADK
winget install Microsoft.ADKPEAddon
goto after-sdk

:install-rufus
winget install Rufus.Rufus
goto after-rufus

:after-sdk
if exist "%localappdata%\Microsoft\WinGet\Packages\Rufus.Rufus_Microsoft.Winget.Source_8wekyb3d8bbwe\rufus.exe" echo [ + ] Rufus Installed!
if exist "%localappdata%\Microsoft\WinGet\Packages\Rufus.Rufus_Microsoft.Winget.Source_8wekyb3d8bbwe\rufus.exe" goto after-rufus
if not exist "%localappdata%\Microsoft\WinGet\Packages\Rufus.Rufus_Microsoft.Winget.Source_8wekyb3d8bbwe\rufus.exe" goto :rufus-not-installed

:after-rufus
if exist "%userprofile%\Desktop\AX-SYS ISO Builder.bat" del "%userprofile%\Desktop\AX-SYS ISO Builder.bat"
echo [ + ] Installing Script
mkdir "%appdata%\AX-SYS"
mkdir "%temp%\AX-SYS"
curl -o "%temp%\AX-SYS\files_layer.7z" "https://raw.githubusercontent.com/FerrousInk/AX-SYS-Tool/main/files.7z"
curl -o "%appdata%\AX-SYS\7zr.exe" "https://www.7-zip.org/a/7zr.exe"
call "%appdata%\AX-SYS\7zr.exe" x "%temp%\AX-SYS\files_layer.7z" -o"%temp%\AX-SYS"
call "%appdata%\AX-SYS\7zr.exe" x "%temp%\AX-SYS\files.7z" -o"%appdata%\AX-SYS"
del "%appdata%\AX-SYS.temp.7z"
move "%appdata%\AX-SYS\iso_builder.txt" "%userprofile%\Desktop\AX-SYS ISO Builder.bat"
if not exist "%userprofile%\Desktop\AX-SYS ISO Builder.bat" (goto offline-install) else (goto install-finished)
:offline-install
echo [ - ]
echo [ - ]
echo [ - ]
echo [ - ]
echo [ - ]
echo [ - ] Server not reachable! Please connect to the internet to install latest version of the AX-SYS Tool. This might also be a different error.
pause
exit

:install-finished
echo [ - ]
echo [ - ]
echo [ - ]
echo [ - ]
echo [ - ]
echo [ + ] Install Finished!
pause
exit
