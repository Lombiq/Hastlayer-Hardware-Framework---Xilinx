# AXI Lite interface slave registers



You might want to read/write single pieces of data from/to custom IP cores. In this case you can use the custom IP cores' AXI Lite interface, in which there are 32 bit datawidth slave registers (so far 8, can be extended to 512) which can be addressed from MicroBlaze for read/write operations.

This way you can initiate operations like send start flag or MemberId to the custom IP, or to get notified when operations finish.