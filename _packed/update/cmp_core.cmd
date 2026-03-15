setlocal enabledelayedexpansion

@start /wait _compress\xrCompress.exe gamedata -ltx arch_core.ltx -force

:: init patch dir
set "initial=data"

:: create path
if not exist "%initial%" mkdir "%initial%" 2>nul

:: move and rename
for %%f in (gamedata.db?) do (
	if exist "%%f" (
		move "%%f" "%initial%\core.db" >nul 2>&1
	)
)

endlocal