@echo off

title Launching Xilinx SDK...

FOR /F "tokens=* USEBACKQ" %%F IN (`cscript sdkpath.vbs C:\Xilinx\Vivado\2016.4\bin\unwrapped\win64.o\vvgl.exe`) DO (
SET sdkpath=%%F
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
