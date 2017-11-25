@echo off

title Launching Xilinx SDK...

rem For current user-only installations this key will exist, for system-wide ones the other one.
reg query "HKEY_CURRENT_USER\Software\Classes\Vivado.Project.1\Shell\Open\Command" >nul
if %errorlevel% equ 0 (
	for /f "tokens=4 delims= " %%r in ('reg query "HKEY_CURRENT_USER\Software\Classes\Vivado.Project.1\Shell\Open\Command" /ve') do (
		for /f "usebackq tokens=*" %%p in (`cscript /NoLogo sdkpath.vbs %%r`) do set sdkpath=%%p
	)
) else (
	echo "The registry key of the Vivado shell wasn't found for the current user. Attempting for the local machine."
	for /f "tokens=4 delims= " %%r in ('reg query "HKEY_LOCAL_MACHINE\Software\Classes\Vivado.Project.1\Shell\Open\Command" /ve') do (
		for /f "usebackq tokens=*" %%p in (`cscript /NoLogo sdkpath.vbs %%r`) do set sdkpath=%%p
	)
)


echo Found Xilinx SDK at: %sdkpath%

if exist SDK\Hastlayer_wrapper.hdf GOTO hdf_found
echo "First open the Vivado project, generate bitstream, export project to SDK, then retry."
mshta javascript:alert("First open the Vivado project, generate bitstream, export project to SDK, then retry.");close();
exit
pause
:hdf_found

echo Moving SDK folder...

move SDK SDKImport
mkdir SDK

cmd /c %sdkpath% -batch -source CreateSdkWorkspace.tcl
copy SDKImport\Hastlayer_wrapper.hdf SDK\Hastlayer_wrapper.hdf
copy SDKImport\.launch SDK\.launch
mkdir SDK\.metadata\.plugins\org.eclipse.debug.core\.launches
copy SDKImport\.launch SDK\.metadata\.plugins\org.eclipse.debug.core\.launches\Debug.launch
%sdkpath% -workspace SDK
