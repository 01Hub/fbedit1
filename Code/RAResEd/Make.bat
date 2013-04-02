
@echo off


call:GetIniValue "..\..\Make.ini" "MasmHome" MasmHome


set MasmBin=%MasmHome%\Bin
set MasmInc=%MasmHome%\Include
set MasmLib=%MasmHome%\Lib


echo .
echo *** compiling ASMs ***
"%MasmBin%\ML.EXE" /c /coff /Cp /I"%MasmInc%" "Src\RAResEd.asm" > Make.log || goto ERR_Exit


echo .
echo *** building LIB ***
"%MasmBin%\POLIB.EXE" /verbose /OUT:"Build\RAResEd.lib" RAResEd.obj >> Make.log || goto ERR_Exit


echo .
echo *** exhibit INC ***
xcopy Src\RAResEd.inc Build /d /y || goto ERR_Exit


echo .
echo *** cleanup ***
del RAResED.obj || goto ERR_Exit



:OK_Exit
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo .
echo .
echo .
pause
exit 0

:ERR_Exit
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
Make.log
pause
exit 1


rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof
