# Hastlayer Hardware Framework - Xilinx readme

This document is a guideline which provides a brief description of the **Hastlayer Hardware Framework** for Xilinx FPGAs. The aim of this document is to help the reader to reconstruct and test the **Hastlayer FPGA firmware design** and to give a hand when you run into a problem.

If you're not familiar with Hastlayer take a look at [https://hastlayer.com/](https://hastlayer.com/).

**Note** that unfortunately, due to the compatibility of the FPGA development software Vivado, this project only works up to Windows 10, but not with Windows 11. Running Vivado in Windows 8 compatibility mode (configuring this for _C:\Xilinx\Vivado\2016.4\bin\unwrapped\win64.o\vivado.exe_ and _C:\Xilinx\Vivado\2016.4\bin\unwrapped\win64.o\vvgl.exe_) doesn't help.

## Table of contents

- [Prerequisite requirements](Docs/Prerequisites.md)
- [Getting started](Docs/GettingStarted.md)
- [Running hardware designs](Docs/RunningHardwareDesigns.md)
- [Release notes](Docs/ReleaseNotes.md)
- [Version control](Docs/VersionControl.md)
- [Upgrading the project to the latest Vivado version](Docs/UpgradingToNewVivado.md)
- [Design reproduction steps](Docs/ReproductionSteps.md)
- [Testing custom IP cores](Docs/Testing.md)
- [AXI Lite interface slave registers](Docs/AxiSlaveRegisters.md)
- [Adding custom library functions to the design](Docs/CustomLibraryFunctions.md)
- [Debugging with an ILA core](Docs/IlaDebugging.md)
