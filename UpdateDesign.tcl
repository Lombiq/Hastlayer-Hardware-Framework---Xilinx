# Opening the project
open_project ./Project/Hastlayer.xpr

# Updating Hast_IP
# First touching the file so Vivado notice it changing and so the IP can be updated.
file mtime ./IPRepo/Hast_IP.vhd [clock seconds]
update_ip_catalog -rebuild -scan_changes
report_ip_status -name ip_status
upgrade_ip -vlnv xilinx.com:user:Hast_IP:1.0 [get_ips  Hastlayer_Hast_IP_0_0] -log ip_upgrade.log
export_ip_user_files -of_objects [get_ips Hastlayer_Hast_IP_0_0] -no_script -sync -force -quiet
generate_target all [get_files  ./Project/Hastlayer.srcs/sources_1/bd/Hastlayer/Hastlayer.bd]
export_ip_user_files -of_objects [get_files ./Project/Hastlayer.srcs/sources_1/bd/Hastlayer/Hastlayer.bd] -no_script -sync -force -quiet
export_simulation -of_objects [get_files ./Project/Hastlayer.srcs/sources_1/bd/Hastlayer/Hastlayer.bd] -directory ./Project/Hastlayer.ip_user_files/sim_scripts -ip_user_files_dir ./Project/Hastlayer.ip_user_files -ipstatic_source_dir ./Project/Hastlayer.ip_user_files/ipstatic -lib_map_path [list {modelsim=./Project/Hastlayer.cache/compile_simlib/modelsim} {questa=./Project/Hastlayer.cache/compile_simlib/questa} {riviera=./Project/Hastlayer.cache/compile_simlib/riviera} {activehdl=./Project/Hastlayer.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet

# Generating bitstream
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 8