# Opening the project
open_project ./Project/Hastlayer.xpr

# Launching the SDK
file copy -force ./Project/Hastlayer.runs/impl_1/Hastlayer_wrapper.sysdef ./SDK/Hastlayer_wrapper.hdf
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