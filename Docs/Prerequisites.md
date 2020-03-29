# Prerequisite requirements



On this page you can find the system requirements and necessary preparations for creating a design in Vivado for the Nexys4DDR development board.


## Hardware requirements

On the [Xilinx memory recommendations](http://www.xilinx.com/design-tools/vivado/memory.htm) site you can find Xilinx FPGA's memory requirements for various OS. On the Nexys4DDR board there is an XC7A100T FPGA, for which Xilinx recommends 3 GB of memory (Windows, 64 bit OS).


## Software requirements

Use Vivado **2017.1 (64-bit)** and the corresponding Xilinx Software Development Kit (SDK). Some notes:

- Use exactly the above version. No other version, be it newer or older, will be compatible.
- You can download the WebPACK version of Vivado for free from [Xilinx's website](https://www.xilinx.com/support/download.html).
- Install Vivado under a path without special characters or spaces and also put your projects under similarly simple paths! Otherwise a lot of things will mysteriously fail in Vivado (e.g. with the TCL error "TclStackFree: incorrect freePtr. Call out of sequence?") and also in Xilinx SDK. You can also use symlinks to provide such a path to an otherwise problematic one.
- During installation, when you need to select the Xilinx devices to install, you only need to add Artix-7. You can deselect all other devices, this way you will save some disk space.

	![Vivado installation items](Images/VivadoInstallationItems.png)


## Digilent Nexys A7 / Nexys 4 DDR board files installation

Download the **Digilent board files** from and follow the instructions on the [Digilent website](https://reference.digilentinc.com/vivado/installing-vivado/start). Now you should be able to choose Digilent boards in Vivado when you create a new project.