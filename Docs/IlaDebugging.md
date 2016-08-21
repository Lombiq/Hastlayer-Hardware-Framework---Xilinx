# Debugging with an ILA core



You can add and setup an ILA (Integrated Logic Analyzer) core to the hardware design from the IP Catalog. The ILA core's input probes come from the custom IP's ports. With the use of ILA core you can monitor operation of our custom IP cores.

For a step-by-step tutorial of how to set up and use ILA core find the [ug940 Vivado Design Suite Tutorial Embedded Processor Hardware Design user guide] (http://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_3/ug940-vivado-tutorial-embedded-design.pdf). 

**Note**: At ug940 Step 3: Connect to the Vivado Logic Analyzer section, if you don't find the hw_ila_1(ILA) int your Hardware Manager window under the device, check the previous section (Program FPGA in the SDK, and run the SDK test. After this, reprogram device in Vivado Hardware Manager, and now you should see the hw_ila_1(ILA) under the device).

Other useful literature: to learn more about Integrated Logic Analyzer check [UG908 - Vivado Programming and Debugging guide](http://www.xilinx.com/support/documentation/sw_manuals/xilinx2014_4/ug908-vivado-programming-debugging.pdf). Useful [Video tutorial](http://video.xilinx.com/services/player/bcpid897165068001?bckey=AQ~~,AAAABAHLGok~,a3rQal6KQNtJvM2KKpOYKAO8SL3feS84&bctid=1809049515001) about debugging with ILA core.