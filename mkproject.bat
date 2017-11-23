@echo off

title Starting Vivado...

if not exist project goto mkproject
echo "The 'Project' folder already exists. To avoid overwriting it by accident, first you have to remove it before generating the project again."
mshta javascript:alert("The \"Project\" folder already exists. To avoid overwriting it by accident, first you have to remove it before generating the project again.");close();
exit

:mkproject

runtcl mkproject.tcl