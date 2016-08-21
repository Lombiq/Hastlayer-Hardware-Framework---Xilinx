# Design reproduction steps



Please follow the steps below to reproduce the Hastlayer Hardware design.


## Create a Vivado IP integrator block design with Microblaze

Follow the instructions of the [Getting Started with Microblaze guide](https://reference.digilentinc.com/nexys4-ddr:gsmb) to make a firmware design which contains a Microblaze soft core processor, Clocking Wizard and System Reset, Block Memory, USB-RS232 UART, and DDR2 Memory Controller (MIG) etc.

During these steps, you will also get a VHDL wrapper file called **Hastlayer_wrapper.vhd** (see description step 38). This wrapper file instantiates your whole IP Integrator Block Design, and it will be functioning as a VHDL top module, in which we will be able to instantiate other IPs too.


## Adding pinout and physical constrains

You will also need to add the **Nexys4DDR_Master.xdc** to the project to generate a bitfile which you will run on the FPGA. Download the [Nexys4DDR_Master.xdc](http://digilentinc.com/Products/Detail.cfm?NavPath=2,1301,1319&Prod=NEXYS4DDR) from Digilent.

In the Nexys4DDR_Master.xdc you will need to uncomment the lines of ports which will go to physical pins of the FPGA. You will also need to rename these ports in the get_ports section appropriate to the port name in your Hastlayer_wrapper.vhd.

**Example**: Notice that the input clock of your design named sys_clock in the Hastlayer_wrapper.vhd entity, but it is called CLK100MHZ in the original Nexys4DDR_Master.xdc. This will cause errors during the bitfile generation (or in case of less important ports like USB_Uart_rxd or USB_Uart_txd they will be optimized out by compiler).

So you have to change these:
>
	set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }]; 
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK100MHZ}];

To these:
>set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { sys_clock }]; 
>create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {sys_clock}];

If you haven't put the right port names in the .xdc file's get_ports sections, you might get an error message like this (which is misleading):
>
	[Common 17-55] 'get_property' expects at least one object. [d:/../../../Hastlayer/>Hastlayer.srcs/sources_1/bd/Hastlayer/ip/Hastlayer_auto_cc_0/Hastlayer_auto_cc_0_clocks.xdc:19]
	Resolution: If [get_<value>] was used to populate the object, check to make sure this comm     and returns at least one valid object.

Check all the other used ports in the .xdc file not to leave any naming mismatch.


## Adding Ethernet Communication Interface

The ethernet interface integration to the Hastlayer design was made with the help of the [Getting Started with Microblaze Servers](https://reference.digilentinc.com/nexys4-ddr:gsmbs) reference design.

**Note**: The reference guide does not cover some important details:

- The Nexys4 DDR board includes an [SMSC 10/100 Ethernet PHY](http://www.microchip.com/wwwproducts/Devices.aspx?product=LAN8720A) which is a RMII (Reduced Media Independent Interface). During building up the Vivado Block Design, you have to add an Ethernet PHY MII to Reduced MII block as well, which provides the interface
between RMII-compliant ethernet physical media devices (PHY) and Xilinx 10/100 Mb/s ethernet cores such as the AXI Ethernet Lite IP which is used in the design.
- When the Hardware design bitstream generation is finished, and you exported the Hardware design to Xilinx SDK, you can make an Echo Server from template to test the Ethernet interface. In this case, you have to have an lwip141 (TCP/IP Stack library) compliant BSP (Board Support Package). This could be made by hand, by opening system.mss in the folder of the already existing Hastlayer_bsp, clicking on "Modify this BSP's Settings", and then adding lwip141 by filling out the checkboy in the Owerview tab. However this not worked in the practice, so creating a new BSP is suggested instead of upgrading the existing one. 

The Ethernet interface passed the Xilinx SDK lwip test successfully on the Nexys4 DDR board.


## Parameterization of the Memory Interface Generator (MIG)

Download the [Xilinx Memory Interface Generator (MIG) Project](https://reference.digilentinc.com/nexys4-ddr:start). You can find it in the Design Resources section. Extract the nexys4ddr_mig_prj.zip to the [Hastlayer Hardware]/Hastlayer.mig/ folder. You will find a readme file in the .zip, follow it's steps. After step 2., you will get the following error message: 
>	
	Could not reload the Non-AXI design in the IPI. Please load the AXI design
	
This happens, becouse the nexys4ddr_mig_prj was made for a non-AXI system. You have to add AXI interface to the memory controller the following way:

You have to find the mig.prj file among the board files you installed in the section **Install Digilent Nexys 4 DDR board files**. Compare this mig.prj file with the other mig.prj file you downloaded for the memory controller. The relevant difference between these two files will be this section:
>
	<PortInterface>AXI</PortInterface>
	<AXIParameters>
	    <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>
	    <C0_S_AXI_ADDR_WIDTH>27</C0_S_AXI_ADDR_WIDTH>
	    <C0_S_AXI_DATA_WIDTH>64</C0_S_AXI_DATA_WIDTH>
	    <C0_S_AXI_ID_WIDTH>1</C0_S_AXI_ID_WIDTH>
	    <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>
	</AXIParameters>

You need to copy this section to the mig.prj file under your project. Now you can restart following the steps of the readme file.  

**Note**: At the pinout stage you have to push validate button to proceed to the next step.


## Creation of AXI interfaced custom IP cores

To make an AXI interfaced custom IP core which can be instantiated in the Vivado IP Integrator block design please follow the steps of the [Creating custom IP block in Vivado](http://www.fpgadeveloper.com/2014/08/creating-a-custom-ip-block-in-vivado.html) guide.

**Note**: At the end of this guide you will also find an example SDK C code for addressing the IP's slave registers from Microblaze for read/write operations.

An important document: [Xilinx AXI reference guide](http://www.xilinx.com/support/documentation/ip_documentation/axi_ref_guide/latest/ug1037-vivado-axi-reference-guide.pdf)


## Create an SDK test project

After you successfully generated the bitstream, you will need to export the Hardware design to the SDK (Software Development Kit). Here you will be able to make basic tests from templates to test USB-UART, Ethernet, DDR2 Memory or other peripherals.

Follow the instructions of the [Getting Started with Microblaze guide](https://reference.digilentinc.com/nexys4-ddr:gsmb) from step 43 once you have the bitstream generated.