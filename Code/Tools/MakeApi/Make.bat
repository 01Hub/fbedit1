@echo off
setlocal enableDelayedExpansion


if "%FBC_PATH%"=="" (
    call:GetIniValue "..\..\..\Make.ini" "FBHome" FBHome
) else (
    set FBHome=!FBC_PATH!
)


echo.
echo *** compiling bas files ***
if /i "%1"=="DEBUG" (
    echo DEBUG
    "!FBHome!\fbc" -v -g "Src\MakeApi.Bas" "Res\MakeApi.Rc" -x "Build\MakeApi.exe" > Make.log || goto ERR_Exit
) else ( 
    echo RELEASE
    "!FBHome!\fbc" -s gui -v "Src\MakeApi.Bas" "Res\MakeApi.Rc" -x "Build\MakeApi.exe" > Make.log || goto ERR_Exit
)


echo.
echo *** exhibit doc files ***
xcopy  /f /y "MakeApi.txt" "Build\*"  >> Make.log || goto ERR_Exit


:OK_Exit
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo .
echo .
echo .
exit /b 0

:ERR_Exit
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
start Make.log
exit /b 1




rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof
