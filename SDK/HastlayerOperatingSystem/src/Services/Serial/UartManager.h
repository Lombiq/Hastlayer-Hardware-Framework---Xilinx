#ifndef UARTMANAGER_H_
#define UARTMANAGER_H_

#include "xparameters.h"
#include <xio.h>
#include "xuartlite_l.h"
#include "xil_types.h"
#include "../../TypeDefinitions.h"


namespace HastlayerOperatingSystem
{

class UartManager
{
public:
	/**
	 * Waits for any input to appear on UART.
	 */
	static void WaitForUartInput();

	/**
	 * Waits for the specified byte to appear on UART.
	 */
	static void WaitForUartInput(byte byteToWaitFor);

	/**
	 * Waits for the UART transmitter to become ready.
	 */
	static void WaitForTransmitterReady();

	/**
	 * Receives a byte of data from UART.
	 */
	static byte ReceiveByte();

	/**
	 * Receives an integer from UART.
	 */
	static int ReceiveInt();

	/**
	 * Sends a byte of data via UART.
	 */
	static void SendByte(byte byteToSend);

	/**
	 * Sends a integer via UART.
	 */
	static void SendInt(int intToSend);
};

} /* namespace HastlayerOperatingSystem */

#endif /* UARTMANAGER_H_ */
