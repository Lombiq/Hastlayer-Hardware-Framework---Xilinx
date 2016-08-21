# Prerequisite requirements



On this page you can find the system requirements and necessary preparations for creating a design in Vivado for the Nexys4DDR development board.


## Hardware requirements

On the [Xilinx memory recommendations](http://www.xilinx.com/design-tools/vivado/memory.htm) site you can find Xilinx FPGA's memory requirements for various OS. On the Nexys4DDR board there is an XC7A100T FPGA, for which Xilinx recommends 3 GB of memory (Windows, 64 bit OS).


## Software requirements

During development the Vivado 2015.4 (64-bit) and the corresponding Xilinx Software Development Kit (SDK) were used. If you use and older version of Vivado, you might find some of the IP's in the Block Design locked. In this case you will need to update old IP's (Vivado indicates them).


## Digilent Nexys 4 DDR board files installation

Download the **Nexys 4 DDR board files** from [Vivado Board Files for Digilent 7-Series FPGA Boards](https://reference.digilentinc.com/vivado:boardfiles2015).

Follow the instructions in the description (merge the contents of the downloaded .zip file with the existing Vivado board files; it can be found under a path like C:\Xilinx\Vivado\2015.4\data\boards\board_files\). Now you should be able to choose the Nexys 4 DDR board in Vivado when you create a new project.