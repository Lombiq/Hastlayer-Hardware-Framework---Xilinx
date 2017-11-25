#!/usr/bin/tclsh
sdk setws SDK
sdk createhw -name Hastlayer_wrapper_hw_platform_0 -hwspec SDKImport/Hastlayer_wrapper.hdf
sdk createbsp -name Hastlayer_bsp -proc microblaze_0 -hwproject Hastlayer_wrapper_hw_platform_0 -os standalone -mss SDKImport/Hastlayer_bsp/system.mss
sdk importprojects SDKImport
sdk build_project -type all
exit
