#include "UartManager.h"

namespace HastlayerOperatingSystem
{

void UartManager::WaitForUartInput()
{
	while (XUartLite_IsReceiveEmpty(XPAR_AXI_UARTLITE_0_BASEADDR))
		;
}

void UartManager::WaitForUartInput(byte byteToWaitFor)
{
	WaitForUartInput();
	if (ReceiveByte() == byteToWaitFor)
	{
		return;
	}

	WaitForUartInput(byteToWaitFor);
}

void UartManager::WaitForTransmitterReady()
{
	while (XUartLite_IsTransmitFull(XPAR_AXI_UARTLITE_0_BASEADDR))
		;
}

byte UartManager::ReceiveByte()
{
	return XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
}

int UartManager::ReceiveInt()
{
	byte inputBuffer[4];

	inputBuffer[0] = ReceiveByte();
	inputBuffer[1] = ReceiveByte();
	inputBuffer[2] = ReceiveByte();
	inputBuffer[3] = ReceiveByte();

	int result = 0;

	result = (result << 8) + inputBuffer[3];
	result = (result << 8) + inputBuffer[2];
	result = (result << 8) + inputBuffer[1];
	result = (result << 8) + inputBuffer[0];

	return result;
}

void UartManager::SendByte(byte byteToSend)
{
	XUartLite_SendByte(XPAR_AXI_UARTLITE_0_BASEADDR, byteToSend);
}

void UartManager::SendInt(int intToSend)
{
	SendByte(intToSend);
	SendByte(intToSend >> 8);
	SendByte(intToSend >> 16);
	SendByte(intToSend >> 24);
}

} /* namespace HastlayerOperatingSystem */
