# Upgrading the project to the latest Vivado version



The TCL file used to generate the project is not fully compatible between Vivado versions.

If the project is not generated correctly in a new version of Vivado, you may have to manually upgrade `CreateProject.tcl`. These are the steps:

1. Generate the project files with the old Vivado version. Open the old Vivado, and run `CreateProject.tcl` from the TCL console.
2. Open `project/Hastlayer.xpr` in the new Vivado version.
3. Rename `CreateProject.tcl` to `CreateProject.tcl.bak`
4. Click on *Write Project Tcl* in the Vivado menu, and for the path select `CreateProject.tcl` in the root of the repo.
5. Manually edit the generated TCL file. First, remove all entries corresponding to log files. Then compare the TCL with the original one (still available as `CreateProject.tcl.bak`) and make all modifications that were made to the original TCL. Look for comments with "@", these help.
6. You will also need to test run the following scripts: CreateProject.bat, CreateBlockDesign.tcl, CreateSdkWorkspace.bat, CreateSdkWorkspace.tcl, RunDesign.bat, RunDesign.tcl, UpdateDesign.bat, UpdateDesign.tcl. You will need to modify the development environment version numbers, the IP versions, and commands (if some of them are deprecated).
7. The new Vivado version possibly also brings new timing values, so the Timing Tester needs to be re-run and the timing reports in device drivers updated.