/******************************************************************************
*
* Copyright (C) 2008 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

#ifndef __PLATFORM_H_
#define __PLATFORM_H_

#define PLATFORM_EMAC_BASEADDR XPAR_AXI_ETHERNETLITE_0_BASEADDR
#define DDR_MEMORY_HAST_IP_BASEADDRESS 0x48FFFFF0
#define PLATFORM_TIMER_BASEADDR XPAR_AXI_TIMER_0_BASEADDR
#define PLATFORM_TIMER_INTERRUPT_INTR XPAR_AXI_INTC_0_AXI_TIMER_0_INTERRUPT_INTR
#define PLATFORM_TIMER_INTERRUPT_MASK (1 << XPAR_AXI_INTC_0_AXI_TIMER_0_INTERRUPT_INTR)
// The clock frequency, in MHz, of the processor.
#define CLOCK_FREQUENCY_MHZ (100)
// The interval, in milliseconds, between timer interrupts.
#define TIMER_INTERVAL_MILLISECONDS (250)
// UART baud rate.
#define UART_BAUD_RATE 230400

enum CommunicationChannel { Ethernet, Serial };


#include "xil_cache.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "arch/cc.h"
#include "xintc.h"
#include "xil_exception.h"
#include "mb_interface.h"
#include "xparameters.h"
#include "xintc.h"
#include "xtmrctr_l.h"

#ifdef STDOUT_IS_16550
	#include "xuartns550_l.h"
#endif

#include "lwip/tcp.h"
#if LWIP_DHCP==1
	#include "lwip/dhcp.h"

	void dhcp_fine_tmr();
	void dhcp_coarse_tmr();
#endif


class Platform
{
public:
	// Initializes platform (ie. initializes caches, UART, etc.).
	static void InitializePlatform(CommunicationChannel communicationChannel);

	// Cleans platform right before exiting the application.
	static void CleanupPlatform();

	// Enables interrupts. It is necessary for Ethernet communication.
	static void EnableInterrupts();
};

#endif
