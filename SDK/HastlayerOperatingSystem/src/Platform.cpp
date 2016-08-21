/******************************************************************************
*
* Copyright (C) 2010 - 2014 Xilinx, Inc.  All rights reserved.
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

#include "Platform.h"
#include "Services/TimerCallbackManager.h"


static XIntc intc;

#if LWIP_DHCP==1
volatile int DhcpTimeoutCounter = 24;
#endif


void XAdapterTimerHandler(void *p)
{
	HastlayerOperatingSystem::TimerCallbackManager::InvokeTimerCallback();

	// Load timer, clear interrupt bit.
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0,
			XTC_CSR_INT_OCCURED_MASK
			| XTC_CSR_LOAD_MASK);

	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0,
			XTC_CSR_ENABLE_TMR_MASK
			| XTC_CSR_ENABLE_INT_MASK
			| XTC_CSR_AUTO_RELOAD_MASK
			| XTC_CSR_DOWN_COUNT_MASK);

	XIntc_AckIntr(XPAR_INTC_0_BASEADDR, PLATFORM_TIMER_INTERRUPT_MASK);
}

void SetupTimer()
{
	// Set the number of cycles the timer counts before interrupting.
	// 100 Mhz clock => .01us for 1 clk tick. For 100ms, 10000000 clk ticks need to elapse.
	long clockCycles = CLOCK_FREQUENCY_MHZ * 1000000 / (1000 / (float)TIMER_INTERVAL_MILLISECONDS);
	XTmrCtr_SetLoadReg(PLATFORM_TIMER_BASEADDR, 0, clockCycles);

	// Reset the timers, and clear interrupts.
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0, XTC_CSR_INT_OCCURED_MASK | XTC_CSR_LOAD_MASK );

	// Start the timers.
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0,
			XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_ENABLE_INT_MASK
			| XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_DOWN_COUNT_MASK);

	// Register Timer handler.
	XIntc_RegisterHandler(XPAR_INTC_0_BASEADDR,
			PLATFORM_TIMER_INTERRUPT_INTR,
			(XInterruptHandler)XAdapterTimerHandler,
			0);
}

void SetupInterrupts()
{
	XIntc *intcp;
	intcp = &intc;

	XIntc_Initialize(intcp, XPAR_INTC_0_DEVICE_ID);
	XIntc_Start(intcp, XIN_REAL_MODE);

	// Start the interrupt controller.
	XIntc_MasterEnable(XPAR_INTC_0_BASEADDR);

	microblaze_register_handler((XInterruptHandler)XIntc_InterruptHandler, intcp);

	SetupTimer();

#ifdef XPAR_ETHERNET_MAC_IP2INTC_IRPT_MASK
	// Enable timer and EMAC interrupts in the interrupt controller.
	XIntc_EnableIntr(XPAR_INTC_0_BASEADDR, PLATFORM_TIMER_INTERRUPT_MASK | XPAR_ETHERNET_MAC_IP2INTC_IRPT_MASK);
#endif


#ifdef XPAR_INTC_0_LLTEMAC_0_VEC_ID
	XIntc_Enable(intcp, PLATFORM_TIMER_INTERRUPT_INTR);
	XIntc_Enable(intcp, XPAR_INTC_0_LLTEMAC_0_VEC_ID);
#endif


#ifdef XPAR_INTC_0_AXIETHERNET_0_VEC_ID
	XIntc_Enable(intcp, PLATFORM_TIMER_INTERRUPT_INTR);
	XIntc_Enable(intcp, XPAR_INTC_0_AXIETHERNET_0_VEC_ID);
#endif


#ifdef XPAR_INTC_0_EMACLITE_0_VEC_ID
	XIntc_Enable(intcp, PLATFORM_TIMER_INTERRUPT_INTR);
	XIntc_Enable(intcp, XPAR_INTC_0_EMACLITE_0_VEC_ID);
#endif
}

void EnableCaches()
{
#ifdef XPAR_MICROBLAZE_USE_ICACHE
    Xil_ICacheEnable();
#endif
#ifdef XPAR_MICROBLAZE_USE_DCACHE
    Xil_DCacheEnable();
#endif
}

void InitializeMicroBlazeCache()
{
	// Initialize MicroBlaze cache.
	microblaze_disable_dcache();
	microblaze_invalidate_dcache();
	microblaze_flush_dcache();
	microblaze_disable_icache();
	microblaze_invalidate_icache();
}

void DisableCaches()
{
    Xil_DCacheDisable();
    Xil_ICacheDisable();
}

void InitializeUart()
{
#ifdef STDOUT_IS_16550
	XUartNs550_SetBaud(STDOUT_BASEADDR, XPAR_XUARTNS550_CLOCK_HZ, UART_BAUD_RATE);
    XUartNs550_SetLineControlReg(STDOUT_BASEADDR, XUN_LCR_8_DATA_BITS);
#endif
#ifdef STDOUT_IS_PS7_UART
    // Bootrom/BSP configures PS7 UART to 115200 bps.
#endif
}


void Platform::EnableInterrupts()
{
	microblaze_enable_interrupts();
}

void Platform::InitializePlatform(CommunicationChannel communicationChannel)
{
	EnableCaches();

	if (communicationChannel == Serial) InitializeUart();
	else if (communicationChannel == Ethernet)
	{
		// Interrupts wouldn't work with an UART baud rate higher than 9600 any way since XIntc_Start() hangs for some
		// reason.
		SetupInterrupts();
	}

	InitializeMicroBlazeCache();
}

void Platform::CleanupPlatform()
{
    DisableCaches();
}

