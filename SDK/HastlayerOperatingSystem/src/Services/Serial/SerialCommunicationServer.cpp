#include "SerialCommunicationServer.h"


namespace HastlayerOperatingSystem
{

void SerialCommunicationServer::StartSerialCommunicationServer()
{
	// This loop continuously listens for input.
	while (true)
	{
		UartManager::WaitForUartInput();

		// The first received byte represents the command type.
		char commandType = UartManager::ReceiveByte();

		switch (commandType)
		{
			case CommandTypes::WhoIsAvailable:
				UartManager::WaitForTransmitterReady();
				UartManager::SendByte(SerialCommunicationConstants::Signals::Ready);
				break;

			case CommandTypes::Execution:

				// Receiving the input byte count and the member ID from UART, then saving them to memory.
				unsigned int inputByteCount = UartManager::ReceiveInt();

				UartManager::WaitForUartInput();

				int memberId = UartManager::ReceiveInt();
				RegisterManager::SetMemberId(memberId);

				// Saving the input to memory.
				unsigned int receivedByteCounter = 0;
				unsigned int currentMemoryBaseAddressOffset = 0;
				while (inputByteCount > receivedByteCounter)
				{
					MemoryManager::CopyIntegerToInputOutputArea(UartManager::ReceiveInt(), &currentMemoryBaseAddressOffset);

					receivedByteCounter += 4;
				}

				RegisterManager::RunAndWait();


				UartManager::SendByte(SerialCommunicationConstants::Signals::Ping);
				UartManager::WaitForUartInput(SerialCommunicationConstants::Signals::Ready);

				// Sending execution information.
				UartManager::WaitForTransmitterReady();
				// The execution time is stored as a 64b unsigned integer in the 4th and 5th slave registers.
				int* executionTimeAddress = (int*)RegisterManager::GetExecutionTimeAddress();
				UartManager::SendInt(*executionTimeAddress);
				UartManager::SendInt(*(executionTimeAddress + 1));

				UartManager::WaitForUartInput(SerialCommunicationConstants::Signals::Ready);

				// Sending the output byte count.
				// For now it's the same as the input but we can optimize for smaller outputs (or allow bigger outputs) later.
				unsigned int outputBytesCount = inputByteCount;
				UartManager::WaitForTransmitterReady();
				UartManager::SendInt(outputBytesCount);

				UartManager::WaitForUartInput(SerialCommunicationConstants::Signals::Ready);

				// Sending the output.
				UartManager::WaitForTransmitterReady();
				currentMemoryBaseAddressOffset = 0;
				unsigned long* inputOutputMemoryAddress = (unsigned long*)MemoryManager::GetInputOutputMemoryBaseAddress();
				for (unsigned int i = 1; i <= outputBytesCount / 4; i++)
				{
					UartManager::SendInt(*(inputOutputMemoryAddress + currentMemoryBaseAddressOffset));
					currentMemoryBaseAddressOffset++;
				}

				UartManager::WaitForUartInput(SerialCommunicationConstants::Signals::Ready);
			break; // Case 0 END.
		} // SWITCH END.
	} // WHILE END.
}

} /* namespace HastlayerOperatingSystem */
