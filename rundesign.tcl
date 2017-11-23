# Opening the project
open_project ./Project/Hastlayer.xpr

# Exporting the design to the SDK
file copy -force ./Project/Hastlayer.runs/impl_1/Hastlayer_wrapper.sysdef ./SDK/Hastlayer_wrapper.hdf

# Launching the SDK
# This is what Vivado also does and seems to work fine, but it might be necessary to use the SDK export code from here: http://www.fpgadeveloper.com/2016/11/tcl-automation-tips-for-vivado-xilinx-sdk.html
launch_sdk -workspace ./SDK -hwspec ./SDK/Hastlayer_wrapper.hdf

# Programming the FPGA
open_hw
connect_hw_server
open_hw_target
set_property PROGRAM.FILE {./Project/Hastlayer.runs/impl_1/Hastlayer_wrapper.bit} [lindex [get_hw_devices xc7a100t_0] 0]
current_hw_device [lindex [get_hw_devices xc7a100t_0] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a100t_0] 0]
set_property PROBES.FILE {} [lindex [get_hw_devices xc7a100t_0] 0]
set_property PROGRAM.FILE {./Project/Hastlayer.runs/impl_1/Hastlayer_wrapper.bit} [lindex [get_hw_devices xc7a100t_0] 0]
program_hw_devices [lindex [get_hw_devices xc7a100t_0] 0]
refresh_hw_device [lindex [get_hw_devices xc7a100t_0] 0]

exit