# NOTE: In order to use this script for source control purposes, please make sure that the
#       following files are added to the source control system:-
#
# 1. This project restoration tcl script (hastlayer_project.tcl) that was generated.
#
# 2. The following source(s) files that were local or imported into the original project.
#    (Please see the '$orig_proj_dir' and '$origin_dir' variable setting below at the start of the script)
#
#    "N:/lombiq/fm/new14-tcl/Hastlayer.srcs/sources_1/bd/Hastlayer/Hastlayer.bd"
#    "N:/lombiq/fm/new14-tcl/Hastlayer.srcs/sources_1/imports/hdl/Hastlayer_wrapper.vhd"
#    "N:/lombiq/fm/new14-tcl/Hastlayer.srcs/sources_1/bd/Hastlayer/ip/Hastlayer_mig_7series_0_0/board.prj"
#    "N:/lombiq/fm/new14-tcl/Hastlayer.srcs/sources_1/bd/Hastlayer/ip/Hastlayer_mig_7series_0_0/mig_a.prj"
#    "N:/lombiq/fm/new14-tcl/Nexys4DDR_Master.xdc"

# @ manually edited: removed a lot of references to unnecessary log files

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

variable script_file
set script_file "hastlayer_project.tcl"

# Help information for this script
proc help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < [llength $::argc]} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir" { incr i; set origin_dir [lindex $::argv $i] }
      "--help"       { help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/"]"

# @ manually edited: added -force
# Create project
create_project -force Hastlayer ./Project

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects Hastlayer]
set_property "board_part" "digilentinc.com:nexys4_ddr:part0:1.1" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$origin_dir/IPRepo"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset objectobject
#set obj [get_filesets sources_1]
#set files [list \
# "[file normalize "$origin_dir/sources/bd/Hastlayer/ip/Hastlayer_mig_7series_0_0/mig_a.prj"]"\
# "[file normalize "$origin_dir/sources/bd/Hastlayer/ip/Hastlayer_mig_7series_0_0/board.prj"]"\
# "[file normalize "$origin_dir/sources/bd/Hastlayer/Hastlayer.bd"]"\
#]
#add_files -norecurse -fileset $obj $files

# Import local files from the original project
# "[file normalize "$origin_dir/sources/bd/Hastlayer/ip/Hastlayer_mig_7series_0_0/mig_a.prj"]"\
# "[file normalize "$origin_dir/sources/bd/Hastlayer/ip/Hastlayer_mig_7series_0_0/board.prj"]"\
# "[file normalize "$origin_dir/sources/bd/Hastlayer/Hastlayer.bd"]"\

set files [list \
 "[file normalize "$origin_dir/Sources/imports/hdl/Hastlayer_wrapper.vhd"]"\
]
set imported_files [import_files -fileset sources_1 $files]

# Set 'sources_1' fileset file properties for remote files
# None

# @ manually edited: Make block design
source CreateBlockDesign.tcl

# Set 'sources_1' fileset file properties for local files
set file "Hastlayer/Hastlayer.bd"
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
if { ![get_property "is_locked" $file_obj] } {
  set_property "generate_synth_checkpoint" "0" $file_obj
}

set file "hdl/Hastlayer_wrapper.vhd"
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" "Hastlayer_wrapper" $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/Nexys4DDR_Master.xdc"]"
set file_imported [import_files -fileset constrs_1 $file]
set file "Nexys4DDR_Master.xdc"
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property "target_constrs_file" "[file normalize "$origin_dir/Nexys4DDR_Master.xdc"]" $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "Hastlayer_wrapper" $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7a100tcsg324-1 -flow {Vivado Synthesis 2016} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2016" [get_runs synth_1]
}
set obj [get_runs synth_1]

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7a100tcsg324-1 -flow {Vivado Implementation 2016} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2016" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:Hastlayer"

reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1 

# Exporting the design to the SDK
file copy -force ./Project/Hastlayer.runs/impl_1/Hastlayer_wrapper.sysdef ./SDK/Hastlayer_wrapper.hdf