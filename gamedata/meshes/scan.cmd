@echo off
setlocal enabledelayedexpansion

set "root_folder=Y:\sources\Objects\dynamics"
set "output_file=Y:\result.log"

if exist "%output_file%" del "%output_file%"

set "temp_file=%temp%\temp_sort.log"
if exist "%temp_file%" del "%temp_file%"

for /r "%root_folder%" %%f in (*) do (
	set "full_path=%%f"
	set "relative_path=!full_path:%root_folder%\=!"
	set "relative_path=!relative_path:~0,-7!"
	echo dynamics\!relative_path! = !relative_path! >> "%temp_file%"
)

sort "%temp_file%" > "%output_file%"
del "%temp_file%"