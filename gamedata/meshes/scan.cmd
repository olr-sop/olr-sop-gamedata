@echo off
setlocal enabledelayedexpansion

set "scan_root=S:\resources\sources\objects\dynamics"
set "out=S:\resources\batch_all.ltx"
set "omf=%scan_root%\anims"

if exist "%out%" del "%out%"

set "filebuffer=%temp%\temp.log"
if exist "%filebuffer%_omf" del "%filebuffer%_omf"
if exist "%filebuffer%_ogf" del "%filebuffer%_ogf"

for /r "%scan_root%" %%f in (*.object) do (
	set "initial=%%f"
	set "fn=!initial:%scan_root%\=!"
	set "fn=!fn:~0,-7!"

	echo !initial! | find /i "%omf%" >nul
	if !errorlevel!==0 (
		set "fn_omf=!fn:anims\=!"
		echo dynamics\!fn! = !fn_omf!>> "%filebuffer%_omf"
	) else (
		echo dynamics\!fn! = !fn!>> "%filebuffer%_ogf"
	)
)

echo [omf]>> "%out%"
if exist "%filebuffer%_omf" (
	sort "%filebuffer%_omf" >> "%out%"
	del "%filebuffer%_omf"
)

echo. >> "%out%"
echo [ogf]>> "%out%"
if exist "%filebuffer%_ogf" (
	sort "%filebuffer%_ogf" >> "%out%"
	del "%filebuffer%_ogf"
)