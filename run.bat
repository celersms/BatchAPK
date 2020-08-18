@echo off
SETLOCAL
PUSHD "%~dp0"
REM Uninstall previous version of the app, if any
adb uninstall com.celer.hello
adb install "%~dp0\bin\hello.apk"
pause
POPD
ENDLOCAL
@echo on
