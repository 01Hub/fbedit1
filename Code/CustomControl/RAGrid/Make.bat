
@echo off


call:GetIniValue "..\..\..\Make.ini" "MasmHome" MasmHome


set MasmBin=%MasmHome%\Bin
set MasmInc=%MasmHome%\Include
set MasmLib=%MasmHome%\Lib


if not exist Build (mkdir Build)


echo .
echo *** compiling RC ***
"%MasmBin%\RC.EXE" /v /fo"RAGrid.res" Src\RAGrid.rc > Make.log || goto ERR_Exit


echo .
echo *** compiling ASMs ***
"%MasmBin%\ML.EXE" /DDLL /c /coff /Cp /I"%MasmInc%" "Src\RAGrid.asm" >> Make.log || goto ERR_Exit


echo .
echo *** linking DLL ***
"%MasmBin%\LINK.EXE" /verbose /SUBSYSTEM:WINDOWS /RELEASE /DLL /DEF:Src\RAGrid.def /LIBPATH:"%MasmLib%" /OUT:"Build\RAGrid.dll" RAGrid.obj RAGrid.res >> Make.log || goto ERR_Exit
move Build\RAGrid.lib Build\libRAGrid.dll.a || goto ERR_Exit


echo .
echo *** compiling ASMs ***
"%MasmBin%\ML.EXE" /c /coff /Cp /I"%MasmInc%" "Src\RAGrid.asm" >> Make.log || goto ERR_Exit


echo .
echo *** building LIB ***
"%MasmBin%\POLIB.EXE" /verbose /OUT:"Build\RAGrid.lib" RAGrid.obj >> Make.log || goto ERR_Exit


echo .
echo *** exhibit INC ***
xcopy Src\RAGrid.inc Build /d /y || goto ERR_Exit


echo .
echo *** cleanup ***
del RAGrid.obj || goto ERR_Exit
del RAGrid.res || goto ERR_Exit


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
Make.log
exit /b 1


rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof
