:: Let's assume that everything inside gamedata is ready for build

@echo off
setlocal enabledelayedexpansion

echo Start building process...

mkdir _packed\update

if exist bin (
	echo start copy bins...
	xcopy /E /I /Y bin\Win32 _packed\update\bin\Win32\
) else (
	echo Game bins don't exist, SKIP.
)

if exist gamedata (
	echo start copy resources...
	xcopy /E /I /Y gamedata _packed\update\gamedata\
) else (
	echo gamedata don't exist!
	pause
)

pushd _packed\update

echo start compressing resource-core files...
if exist cmp_core.cmd (
	call cmp_core.cmd
) else (
	echo ERROR: cmp_core.cmd not exist, pls, make git pull
)

echo start compressing levels...
if exist cmp_levels.cmd (
	call cmp_levels.cmd
) else (
	echo ERROR: cmp_levels.cmd not exist, pls, make git pull
)

echo start compressing target files...
if exist cmp_resources.cmd (
	call cmp_resources.cmd
) else (
	echo ERROR: cmp_resources.cmd not exist, pls, make git pull
)

popd

echo remove open data
if exist "_packed\update\gamedata" (
	rmdir /S /Q "_packed\update\gamedata"
)

echo Done
pause