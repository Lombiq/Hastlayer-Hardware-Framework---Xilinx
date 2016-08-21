#include "InputOutputMemoryTcpAcceptCallbackProvider.h"
#include "EthernetManager.h"


namespace HastlayerOperatingSystem
{

static struct InputOutputMemoryCommunicationContext* _activeInputOutputCommunicationContext = NULL;


static err_t CloseConnection(struct tcp_pcb *controlBlock, struct InputOutputMemoryCommunicationContext *context)
{
	HASTLAYER_DEBUG_INFORMATION("Closing TCP connection and freeing up context (control block: 0x%0X, context: 0x%0X).", controlBlock, context);

	tcp_recv(controlBlock, NULL);
	tcp_err(controlBlock, NULL);
	tcp_sent(controlBlock, NULL);

	if (context == _activeInputOutputCommunicationContext)
	{
		_activeInputOutputCommunicationContext = NULL;
		HASTLAYER_DEBUG_INFORMATION("Active context was reset.", NULL);
	}

	if (context != NULL)
	{
		mem_free(context);

		HASTLAYER_DEBUG_INFORMATION("Context memory freed up (address: 0x%0X).", context);
	}

	err_t result = tcp_close(controlBlock);

	HASTLAYER_DEBUG_INFORMATION_IF(result == ERR_OK, "Successfully closed TCP connection (control block: 0x%0X).", controlBlock);
	HASTLAYER_DEBUG_ERROR_IF(result != ERR_OK, "Failed to close TCP connection (error: 0x%d, control block: 0x%0X).", result, controlBlock);

	return result;
}

static err_t TcpEnqueue(struct tcp_pcb *controlBlock, const void *dataPointer, u16_t length)
{
	HASTLAYER_DEBUG_INFORMATION("Trying to enqueue data (data pointer: 0x%0X, length: %d, control block: 0x%0X).", dataPointer, length, controlBlock);

	// We need to use TCP_WRITE_FLAG_COPY to move the bytes to a common buffer area. It makes memory management safer.
	err_t result = tcp_write(controlBlock, dataPointer, length, TCP_WRITE_FLAG_COPY);

	HASTLAYER_DEBUG_INFORMATION_IF(result == ERR_OK, "Successfully enqueued data (data pointer: 0x%0X, control block: 0x%0X).", dataPointer, controlBlock);
	HASTLAYER_DEBUG_ERROR_IF(result != ERR_OK, "Failed to enqueue data (error: 0x%d, data pointer: 0x%0X, control block: 0x%0X).", result, dataPointer, controlBlock);

	return result;
}

static void SendReadySignal(struct InputOutputMemoryCommunicationContext *context)
{
	_activeInputOutputCommunicationContext = context;

	context->Signal = EthernetCommunicationConstants::Signals::Ready;
	if (tcp_sndbuf(context->ControlBlock) > 1)
	{
		TcpEnqueue(context->ControlBlock, &context->Signal, 1);
	}

	context->State = EthernetCommunicationConstants::TcpCommunicationStates::ReceivingInput;
}

static void TcpErrorCallback(void *tcpArgument, err_t errorResult)
{
	HASTLAYER_DEBUG_ERROR("TCP error is occurred (error code: %d)", errorResult);

	struct InputOutputMemoryCommunicationContext *context = (struct InputOutputMemoryCommunicationContext *)tcpArgument;
	if (context != NULL)
	{
		HASTLAYER_DEBUG_ERROR("Freeing up context after TCP error (ID: %d)", context->ConnectionId);

		// Something wrong happened to the TCP connection so we need to free the context memory up.
		if (_activeInputOutputCommunicationContext == context)
		{
			_activeInputOutputCommunicationContext = NULL;
		}

		mem_free(context);
	}
}

static err_t PacketSentCallback(void *tcpArgument, struct tcp_pcb *controlBlock, u16_t length)
{
	struct InputOutputMemoryCommunicationContext *context = (struct InputOutputMemoryCommunicationContext*)tcpArgument;

	context->SentByteCount += length;
	context->EnqueuedByteCount -= length;

	HASTLAYER_DEBUG_INFORMATION("Output bytes has been sent (sent bytes count: %d).", context->SentByteCount);

	// Everything sent successfully, close the connection.
	if (context->EnqueuedByteCount == 0 && context->SentByteCount == context->TotalOutputByteCount)
	{
		HASTLAYER_DEBUG_INFORMATION("All output bytes have been sent. Closing connection.", NULL);

		CloseConnection(controlBlock, context);
	}
	// Still have bytes to send.
	else if (context->EnqueuedByteCount == 0)
	{
		context->CurrentSendingBufferSize = tcp_sndbuf(controlBlock);
		if (context->CurrentSendingBufferSize == 0)
		{
			// Buffer size should be changed to its original value if all the enqueued data has been sent so something went wrong unexpectedly.
			HASTLAYER_DEBUG_ERROR("The sender buffer size is 0 after sending all the enqueued bytes, closing connection (ID: %d, control block: 0x%0X).", context->ConnectionId, controlBlock);

			CloseConnection(controlBlock, context);

			return ERR_MEM;
		}

		context->RemainingOutputByteCount = context->TotalOutputByteCount - context->SentByteCount;
		context->EnqueuedByteCount = context->RemainingOutputByteCount > context->CurrentSendingBufferSize
				? context->CurrentSendingBufferSize
				: context->RemainingOutputByteCount;

		HASTLAYER_DEBUG_INFORMATION("All enqueued bytes have been sent. Enqueuing more bytes (length: %d).", context->EnqueuedByteCount);

		Xuint32* memoryAddress = (Xuint32*)MemoryManager::GetInputOutputMemoryBaseAddress() + context->CurrentMemoryBaseAddressOffset;
		err_t result = TcpEnqueue(controlBlock, (const void*)memoryAddress, context->EnqueuedByteCount);
		context->CurrentMemoryBaseAddressOffset += context->EnqueuedByteCount / 4;

		// Something unexpected happened.
		if (result != ERR_OK)
		{
			CloseConnection(controlBlock, context);
		}

		return result;
	}

	return ERR_OK;
}

static void SendResult()
{
	RegisterManager::SetStartSignal(false);

	HASTLAYER_DEBUG_INFORMATION("Processing input bytes has been finished. Sending the result back.", NULL);

	struct InputOutputMemoryCommunicationContext *context = _activeInputOutputCommunicationContext;

	context->State = EthernetCommunicationConstants::TcpCommunicationStates::SendingOutput;

	// Assign a TCP sent callback to monitor the ACK packets coming from the PC and also enqueue a new buffer to send if necessary.
	tcp_sent(context->ControlBlock, PacketSentCallback);

	context->CurrentSendingBufferSize = tcp_sndbuf(context->ControlBlock);
	void* executionTimeAddress = RegisterManager::GetExecutionTimeAddress();
	err_t result = TcpEnqueue(context->ControlBlock, executionTimeAddress, 8);

	if (result != ERR_OK)
	{
		CloseConnection(context->ControlBlock, context);
	}

	context->OutputByteCount = context->TotalInputByteCount - 8;
	result = TcpEnqueue(context->ControlBlock, (void*)(&context->OutputByteCount), 4);

	if (result != ERR_OK)
	{
		CloseConnection(context->ControlBlock, context);
	}

	context->TotalOutputByteCount = context->OutputByteCount + 12;
	context->EnqueuedByteCount = context->TotalOutputByteCount > context->CurrentSendingBufferSize
			? context->CurrentSendingBufferSize
			: context->TotalOutputByteCount;
	context->EnqueuedByteCountForOutputBytes = context->EnqueuedByteCount - 12;
	result = TcpEnqueue(context->ControlBlock, MemoryManager::GetInputOutputMemoryBaseAddress(), context->EnqueuedByteCountForOutputBytes);
	context->CurrentMemoryBaseAddressOffset = context->EnqueuedByteCountForOutputBytes / 4;

	if (result != ERR_OK)
	{
		CloseConnection(context->ControlBlock, context);
	}

	HASTLAYER_DEBUG_INFORMATION("Output bytes has been enqueued (enqueued bytes count: %d, total: %d).", context->EnqueuedByteCount, context->TotalOutputByteCount);
}

static err_t PacketReceivedCallback(void *tcpArgument, struct tcp_pcb *controlBlock, struct pbuf *buffer, err_t errorResult)
{
	struct InputOutputMemoryCommunicationContext *context = (struct InputOutputMemoryCommunicationContext *)tcpArgument;

	HASTLAYER_DEBUG_INFORMATION("Packet received (ID: %d, control block: 0x%0X, buffer: 0x%0X).", context->ConnectionId, controlBlock, buffer);

	// Don't read the packet if the buffer is empty.
	if (buffer == NULL)
	{
		HASTLAYER_DEBUG_WARNING("Packet received but buffer is NULL, closing connection (ID: %d, control block: 0x%0X).", context->ConnectionId, controlBlock);
		CloseConnection(controlBlock, context);

		return ERR_OK;
	}

	tcp_recved(controlBlock, buffer->len);

	byte* tcpPayloadAddress = (byte*)buffer->payload;

	// Handle if another client is trying to connect when there is already an active communication.
	if (_activeInputOutputCommunicationContext != NULL && _activeInputOutputCommunicationContext != context)
	{
		HASTLAYER_DEBUG_INFORMATION("Another connection is active (ID: %d).", _activeInputOutputCommunicationContext->ConnectionId);

		if (buffer->len > 0 && *tcpPayloadAddress == CommandTypes::Execution)
		{
			HASTLAYER_DEBUG_INFORMATION("Execution command is aborting the active connection (old ID: %d, new ID: %d). Sending Ready signal.", _activeInputOutputCommunicationContext->ConnectionId, context->ConnectionId);

			CloseConnection(_activeInputOutputCommunicationContext->ControlBlock, _activeInputOutputCommunicationContext);

			SendReadySignal(context);
		}
		else
		{
			if (_activeInputOutputCommunicationContext->State != EthernetCommunicationConstants::TcpCommunicationStates::Closed && tcp_sndbuf(controlBlock) > 1)
			{
				HASTLAYER_DEBUG_INFORMATION("Sending Busy signal.", NULL);

				context->Signal = EthernetCommunicationConstants::Signals::Busy;
				TcpEnqueue(controlBlock, &context->Signal, 1);
			}

			if (_activeInputOutputCommunicationContext->State == EthernetCommunicationConstants::TcpCommunicationStates::Closed)
			{
				CloseConnection(_activeInputOutputCommunicationContext->ControlBlock, _activeInputOutputCommunicationContext);
			}

			CloseConnection(controlBlock, context);
		}
	}
	// There is no active communication and a new client wants to connect.
	else if (_activeInputOutputCommunicationContext == NULL)
	{
		if (buffer->len > 0 && *tcpPayloadAddress == CommandTypes::Execution)
		{
			HASTLAYER_DEBUG_INFORMATION("Accepting Execution command and sending Ready signal.", NULL);

			SendReadySignal(context);
		}
		else
		{
			HASTLAYER_DEBUG_INFORMATION("Execution command was excepted but it was something else. Closing connection.", NULL);

			CloseConnection(controlBlock, context);
		}
	}
	// There is an active communication and possibly the same as the current one.
	else
	{
		if (buffer->len > 0)
		{
			context->CurrentPayloadOffset = 0;

			if (context->TotalInputByteCount == 0)
			{
				if (buffer->len > 7)
				{
					// This number contains the byte count of the program.
					context->InputByteCount = ValueConverters::ReorderBytes((int*)(tcpPayloadAddress + context->CurrentPayloadOffset));
					context->CurrentPayloadOffset += 4;
					context->ReceivedByteCounter += 4;

					context->MemberId = ValueConverters::ReorderBytes((int*)(tcpPayloadAddress + context->CurrentPayloadOffset));
					context->CurrentPayloadOffset += 4;
					context->ReceivedByteCounter += 4;

					RegisterManager::SetMemberId(context->MemberId);

					// The full message size is 8 bytes + inputByteCount.
					context->TotalInputByteCount = 8 + context->InputByteCount;

					HASTLAYER_DEBUG_INFORMATION("Input stream has been initialized (ID: %d, member ID: %d, input byte count: %d).", context->ConnectionId, context->MemberId, context->InputByteCount);
				}
				else
				{
					HASTLAYER_DEBUG_ERROR("Initialization bytes was expected to be more than 7 bytes length (member ID bytes + input byte count bytes) but it's %d bytes length (ID: %d).", buffer->len, context->ConnectionId);

					// Something unexpected is happening. Reset everything.
					CloseConnection(controlBlock, context);
				}
			}

			if (context->TotalInputByteCount != 0)
			{
				context->InputByteCountInCurrentPacket = buffer->len - context->CurrentPayloadOffset;

				HASTLAYER_DEBUG_INFORMATION("Copying input bytes from the current packet (length: %d).", context->InputByteCountInCurrentPacket);

				MemoryManager::CopyIntegersToInputOutputArea((tcpPayloadAddress + context->CurrentPayloadOffset), context->InputByteCountInCurrentPacket, &context->CurrentMemoryBaseAddressOffset);
				context->ReceivedByteCounter += context->InputByteCountInCurrentPacket;

				if (context->TotalInputByteCount <= context->ReceivedByteCounter)
				{
					HASTLAYER_DEBUG_INFORMATION("All input bytes has been received. Processing.", NULL);

					RegisterManager::SetStartSignal(true);
					EthernetManager::SetCallbackForNextFinishedSignal(&SendResult);

					return ERR_OK;
				}
			}
		}
		else
		{
			HASTLAYER_DEBUG_ERROR("Buffer is empty (ID: %d, control block: 0x%0X, buffer: 0x%0X).", context->ConnectionId, controlBlock, buffer);
		}
	}

	HASTLAYER_DEBUG_INFORMATION("Freeing up buffer (ID: %d, control block: 0x%0X, buffer: 0x%0X).", context->ConnectionId, controlBlock, buffer);

	pbuf_free(buffer);

	return ERR_OK;
}

static err_t AcceptConnectionCallback(void *tcpArgument, struct tcp_pcb *newControlBlock, err_t errorResult)
{
	static unsigned int connectionId = 0;

	HASTLAYER_DEBUG_INFORMATION("Accepting TCP connection (ID: %d, control block: 0x%0X).", connectionId, newControlBlock);

	tcp_setprio(newControlBlock, TCP_PRIO_MAX);

	InputOutputMemoryCommunicationContext *context = (struct InputOutputMemoryCommunicationContext*)mem_malloc(sizeof(struct InputOutputMemoryCommunicationContext));

	if (context != NULL)
	{
		context->ConnectionId = connectionId;
		context->Buffer = NULL;
		context->ControlBlock = newControlBlock;
		context->CurrentSendingBufferSize = 0;
		context->CurrentMemoryBaseAddressOffset = 0;
		context->CurrentPayloadOffset = 0;
		context->InputByteCount = 0;
		context->InputByteCountInCurrentPacket = 0;
		context->MemberId = 0;
		context->OutputByteCount = 0;
		context->ReceivedByteCounter = 0;
		context->Signal = ' ';
		context->State = EthernetCommunicationConstants::TcpCommunicationStates::Accepted;
		context->TotalInputByteCount = 0;
		context->EnqueuedByteCount = 0;
		context->EnqueuedByteCountForOutputBytes = 0;
		context->RemainingOutputByteCount = 0;
		context->SentByteCount = 0;
		context->TotalOutputByteCount = 0;

		tcp_arg(newControlBlock, context);

		// Setting the necessary callbacks for the connection.
		tcp_err(newControlBlock, TcpErrorCallback);
		tcp_recv(newControlBlock, PacketReceivedCallback);

		connectionId++;

		return ERR_OK;
	}

	HASTLAYER_DEBUG_ERROR("Allocating memory for context was unsuccessful (ID: %d, control block: 0x%0X).", connectionId, newControlBlock);

	connectionId++;

	return ERR_MEM;
}


tcp_accept_fn InputOutputMemoryTcpAcceptCallbackProvider::GetCallback()
{
	return AcceptConnectionCallback;
}

bool InputOutputMemoryTcpAcceptCallbackProvider::IsCommunicationActive()
{
	return _activeInputOutputCommunicationContext != NULL && _activeInputOutputCommunicationContext->State != EthernetCommunicationConstants::TcpCommunicationStates::Closed;
}

} /* namespace HastlayerOperatingSystem */
