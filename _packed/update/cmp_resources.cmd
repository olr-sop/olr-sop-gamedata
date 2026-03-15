setlocal enabledelayedexpansion

@start /wait _compress\xrCompress.exe gamedata -ltx arch_resources.ltx -force -maxsize 606000

:: init patch dir
set "initial=data\resources"

:: create path
if not exist "%initial%" mkdir "%initial%" 2>nul

:: remove old archive
if exist "%initial%\*" del /q "%initial%\*" 2>nul

:: mask and set digit
set /a add=last_avail+1
set "mask=00!add!"
set "mask=!mask:~-2!"

:: move and rename
for %%f in (gamedata.db*) do (
	if exist "%%f" (
		set "fname=%%~nxf"
		set "mask=!fname:gamedata.db=!"
		rem add senior null
		if "!mask:~1!"=="" set "mask=0!mask!"
		move "%%f" "%initial%\resources.db!mask!" >nul 2>&1
	)
)

endlocal