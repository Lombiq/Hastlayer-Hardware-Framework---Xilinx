#!/usr/bin/tclsh
sdk set_workspace SDK
sdk create_hw_project -name Hastlayer_wrapper_hw_platform_0 -hwspec SDKImport/Hastlayer_wrapper.hdf
sdk create_bsp_project -name Hastlayer_bsp -proc microblaze_0 -hwproject Hastlayer_wrapper_hw_platform_0 -os standalone -mss SDKImport/Hastlayer_bsp/system.mss
sdk import_projects SDKImport
exit
