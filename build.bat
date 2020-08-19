@echo off
SETLOCAL

REM === CONFIGURATION BEGIN =============================================

REM The Android SDK Build Tools location
SET BUILD_TOOLS=%HOMEDRIVE%%HOMEPATH%\AppData\Local\Android\Sdk\build-tools\27.0.3

REM The location of android.jar for the current API level
SET ANDROID_JAR=%HOMEDRIVE%%HOMEPATH%\AppData\Local\Android\Sdk\platforms\android-29\android.jar

REM === CONFIGURATION END ===============================================

TITLE Building the Hello World APK...
PUSHD "%~dp0"
SET PROJ=%~dp0

REM Get JDK path
SET JMINVER=1.6
SET JDK=%JDK_HOME%
IF EXIST "%JDK%\bin\javac.exe" GOTO JDKFOUND
SET JDK=%JAVA_HOME%
IF EXIST "%JDK%\bin\javac.exe" GOTO JDKFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit" /s 2^>nul ^| find "JavaHome"') DO SET JDK=%%j
IF EXIST "%JDK%\bin\javac.exe" GOTO JDKFOUND
FOR /f "tokens=2*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit" /s 2^>nul ^| find "JavaHome"') DO SET JDK=%%j
IF NOT EXIST "%JDK%\bin\javac.exe" GOTO JDKNOTFOUND
:JDKFOUND

REM Cleanup
rd /s /q bin obj >nul 2>nul
mkdir bin obj 2>nul

REM Preprocess resources
cd "%BUILD_TOOLS%"
aapt package -f -m -J "%PROJ%\src" -M "%PROJ%\src\AndroidManifest.xml" -S "%PROJ%\res" -I "%ANDROID_JAR%"
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Compile Java to bytecode
cd "%PROJ%"
"%JDK%\bin\javac" -source %JMINVER% -target %JMINVER% -d obj -classpath src;"%JDK%\jre\lib\jsse.jar" -bootclasspath "%ANDROID_JAR%" src\com\celer\hello\Main.java
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Convert the bytecode to Dex (Dalvik)
cd "%BUILD_TOOLS%"
call dx --dex --output="%PROJ%\bin\classes.dex" "%PROJ%\obj"
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Generate the unaligned and unsigned APK
aapt package -f -m -F "%PROJ%\bin\unaligned.apk" -M "%PROJ%\src\AndroidManifest.xml" -S "%PROJ%\res" -I "%ANDROID_JAR%"
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Add the bytecode to the APK (file copy is needed to ensure the right APK structure)
copy /Y /B "%PROJ%\bin\classes.dex" . 2>nul
aapt add "%PROJ%\bin\unaligned.apk" classes.dex
del classes.dex /q >nul 2>nul

REM Align the APK
zipalign -f 4 "%PROJ%\bin\unaligned.apk" "%PROJ%\bin\aligned.apk"
IF %ERRORLEVEL% NEQ 0 GOTO EXIT

REM Sign the APK
call apksigner sign --ks "%PROJ%\src\demo.keystore" -v1-signing-enabled true -v2-signing-enabled true --ks-pass pass:password --out "%PROJ%\bin\hello.apk" "%PROJ%\bin\aligned.apk"
GOTO EXIT

:JDKNOTFOUND
ECHO JDK not found. If you have JDK %JMINVER% or later installed set JDK_HOME to point to the JDK location.
:EXIT
pause
POPD
ENDLOCAL
@echo on
