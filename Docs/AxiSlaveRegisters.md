# AXI Lite interface slave registers


We use a soft core embedded processor (Microblaze) in the design. The Microblaze processor controls the FPGA IP cores / peripherals via AXI Lite interface. All IP cores in the FPGA design have a base address in the memory, on which you can reach it's registers. You can see the IP cores' addresses in the Address Editor in Vivado.  
You might want to read/write single pieces of data from/to custom IP cores. In this case you can use the custom IP cores' AXI Lite interface, in which there are 32 bit datawidth slave registers (so far 8, can be extended to 512) which can be addressed from MicroBlaze for read/write operations.

This way you can initiate operations like send start flag or MemberId to the custom IP, or to get notified when operations finish.