# Update project to the latest development environment



To Update a Vivado project to the latest Vivado version, do the following steps:

> 1. We use TCL scripts to create our Xilinx Vivado and Xilinx SDK projects. When you update your design to the latest version of Vivado, you will need to check the following files: mkproject.bat; mkproject.tcl; mkbd.tcl; mksdk.bat; mksdk.tcl. You will need to modify the development environment version numbers, the IP versions, and commands (if some of them are deprecated).
> 2. Run mkproject.bat -- This will create the Xilinx Vivado project.
> 3. In Vivado click on Generate Bitstream. Choose ./Project folder. Push the Select button. Click OK. Click Yes.
> 4. After Bitstream Generation Completed, Go to File menu/Export/Export Hardware. Check Include bitstream. Choose ./SDK folder. Click OK.
> 5. Run mksdk.bat -- This will create the Xilinx SDK project.
> 6. In Xilinx SDK, close the Welcome screen. You have to see your projects (ie. HastlayerOperatingSystem), the Board Support Package (ie. Hastlayer_bsp) and the Hardware Platform (ie. Hastlayer_wrapper_hw_platform_0) in your Project Explorer.
> 7. 6. Right Click on the Board Support Package (Hastlayer_bsp). Choose Properties. Under the Project References, choose Hardware Platform (Hastlayer_wrapper_hw_platform_0). Click OK.
> 8. Right Click on the Board Support Package (Hastlayer_bsp). Choose Board Support Package Settings. In the Overview the OS Version is 5.3 by default. Change it to 6.1. Click OK.
> 9. Select your Board Support Package (Hastlayer_bsp) and the application (HastlayerOperatingSystem). Right click on them, and choose Build Project.
> 10. Xilinx Vivado and SDK project creaton and code generations are all done.
