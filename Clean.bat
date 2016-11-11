@echo off

set ROOT=%~dp0
set ROOT=%ROOT:~0,-1%


del /f %ROOT%\Collect.log  2>NUL

rd /s /q %ROOT%\Build  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RACodeComplete\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RACodeComplete\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RAEdit\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RAEdit\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RAFile\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RAFile\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RAGrid\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RAGrid\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RAHexEd\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RAHexEd\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RAProject\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RAProject\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RAProperty\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RAProperty\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RAResEd\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RAResEd\Make.log  2>NUL

rd /s /q %ROOT%\Code\CustomControl\RATools\Build  2>NUL
del /f %ROOT%\Code\CustomControl\RATools\Make.log  2>NUL

rd /s /q %ROOT%\Code\FbEdit\Build  2>NUL
del /f %ROOT%\Code\FbEdit\make.log  2>NUL
del /f %ROOT%\Code\FbEdit\Inc\SVNVersion.bi  2>NUL

rd /s /q %ROOT%\Code\FbEditDLL\Build  2>NUL
del /f %ROOT%\Code\FbEditDLL\make.log  2>NUL

rd /s /q %ROOT%\Code\Tools\FbEditLNG\Build  2>NUL
del /f %ROOT%\Code\Tools\FbEditLNG\Make.log  2>NUL

rd /s /q %ROOT%\Code\Tools\MakeApi\Build  2>NUL
del /f %ROOT%\Code\Tools\MakeApi\Make.log  2>NUL

rd /s /q %ROOT%\Code\VkDebug\Build  2>NUL
del /f %ROOT%\Code\VkDebug\Make.log  2>NUL




echo.
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo.
echo.
echo.
exit /b 0

