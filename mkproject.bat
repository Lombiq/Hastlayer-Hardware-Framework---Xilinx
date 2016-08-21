@echo off

title Starting Vivado...

if not exist project goto mkproject
echo "The 'Project' folder already exists. To avoid overwriting it by accident, first you have to remove it before generating the project again."
mshta javascript:alert("The \"Project\" folder already exists. To avoid overwriting it by accident, first you have to remove it before generating the project again.");close();
exit

:mkproject

rem For current user-only installations this key will exist, for system-wide ones the other one.
reg query "HKEY_CURRENT_USER\Software\Classes\Vivado.Project.1\Shell\Open\Command" >nul
if %errorlevel% equ 0 (
	for /f "tokens=4 delims= " %%r in ('reg query "HKEY_CURRENT_USER\Software\Classes\Vivado.Project.1\Shell\Open\Command" /ve') do (
		echo %%~r
		%%r -source mkproject.tcl
	)
) else (
	echo "The registry key of the Vivado shell wasn't found for the current user. Attempting for the local machine."
	for /f "tokens=4 delims= " %%r in ('reg query "HKEY_LOCAL_MACHINE\Software\Classes\Vivado.Project.1\Shell\Open\Command" /ve') do (
		echo %%~r
		%%r -source mkproject.tcl
	)
)