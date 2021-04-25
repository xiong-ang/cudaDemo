@echo off

call :prepare_env
call :build

goto :EOF

:prepare_env

echo "call env.bat if exist"
if exist env.bat (call env.bat)

goto :EOF

:build

if defined VC_DIR  (
	if defined QT5_9 (echo "VC_DIR and QT5_9 are set.") else (
		echo "please set the 2 env variables: VC_DIR, QT5_9 in env.bat, and retry again."
		pause
		exit
	)
)  else  (
	echo "please set the 2 env variables: VC_DIR, QT5_9 in env.bat, and retry again."
	pause
	exit
)

SET PATH=%QT5_9%;%PATH%
call "%VC_DIR%\vcvarsall.bat" amd64

echo "generating vs sln"
qmake -r -tp vc ./solution.pro
if %errorlevel% NEQ 0 (
	echo "generating vs sln failed"
	pause
	exit
)

echo "build"


devenv solution.sln /Build "Debug|x64"
if %errorlevel% NEQ 0 (
	echo "build Debug version failed"
	pause
	exit
)

devenv solution.sln /Build "Release|x64"
if %errorlevel% NEQ 0 (
	echo "build release version failed"
	pause
	exit
)

goto :EOF