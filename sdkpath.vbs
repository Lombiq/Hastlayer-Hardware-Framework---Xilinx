' This script converts Xilinx Vivado executable path to Xilinx SDK executable path.
' (The Vivado path is stored in the registry, but the SDK path is not. This helper script solves this.)
' Usage: 
'    cscript sdkpath.vbs <Xilinx Vivado executable path>
' Example:
'    cscript /NoLogo sdkpath.vbs C:\Xilinx\Vivado\2015.4\bin\unwrapped\win64.o\vvgl.exe
' Example output:
'    C:\Xilinx\SDK\2015.4\bin\xsdk.bat

Set fso = CreateObject("Scripting.FileSystemObject")
Path = WScript.Arguments.Item(0)
WhereIsVivado = InStr(Path,"\Vivado")
XilinxBaseDir = Left(Path, WhereIsVivado)
'WScript.Echo XilinxBaseDir
AfterVivado = Mid(Path, WhereIsVivado + 8)
'WScript.Echo AfterVivado
WhereIsNextBackslash = InStr(AfterVivado,"\")
DirVersion = Left(AfterVivado, WhereIsNextBackslash-1)
SdkBatchPath = XilinxbaseDir+"SDK\"+DirVersion+"\bin\xsdk.bat"
'WScript.Echo SdkBatchPath
If Not fso.FileExists(SdkBatchPath) Then
	MsgBox "sdkpath.vbs could not find Xilinx SDK at:" + VbCrLf + SdkBatchPath + VbCrLf + "- Check if Xilinx SDK is installed." + VbCrLf + "- Try manually importing projects to the SDK.", 48
End If
WScript.Echo SdkBatchPath