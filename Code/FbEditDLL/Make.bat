
@echo off

call:GetIniValue "..\..\Make.ini" "FBHome" FBHome


if not exist Build (mkdir Build)


echo .
echo *** compiling ***
"%FBHome%\FBC.EXE" -v -dll -Wl "--entry _DLLMAIN@12" "Src\FbEditDLL.bas" "Src\FbEditDLL.rc" -x "Build\FbEdit.dll" > make.log || goto ERR_Exit



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
make.log
exit /b 1


rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof
