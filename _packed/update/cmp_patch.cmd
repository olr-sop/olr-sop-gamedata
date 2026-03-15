setlocal enabledelayedexpansion

@start /wait _compress\xrCompress.exe gamedata -ltx arch_patch.ltx -force

:: init patch dir
set "initial=patches"

:: create path
if not exist "%initial%" mkdir "%initial%" 2>nul

:: finding max count num existing patches
set last_avail=-1
if exist "%initial%\patch_*.xdb" (
	for %%f in ("%initial%\patch_*.xdb") do (
		set "fname=%%~nf"
		set "num_str=!fname:patch_=!"
		set "num=!num_str!"
		:: clean "0"
		for /f "tokens=* delims=0" %%a in ("!num!") do set "num=%%a"
		if "!num!"=="" set "num=0"
		if !num! gtr !last_avail! set last_avail=!num!
	)
)

:: mask and set digit
set /a add=last_avail+1
set "mask=000!add!"
set "mask=!mask:~-3!"

:: move and rename
for %%f in (gamedata.db?) do (
	if exist "%%f" (
		move "%%f" "%initial%\patch_!mask!.xdb" >nul 2>&1
		set /a add+=1
		set "mask=000!add!"
		set "mask=!mask:~-3!"
	)
)

endlocal