#ifndef INPUTOUTPUTMEMORYTCPACCEPTCALLBACKPROVIDER_H_
#define INPUTOUTPUTMEMORYTCPACCEPTCALLBACKPROVIDER_H_

#include "../../Constants/EthernetCommunicationConstants.h"
#include "../../Constants/CommandTypes.h"
#include "AcceptTcpConnectionCallbackProviderBase.h"
#include "../MemoryManager.h"
#include "../RegisterManager.h"
#include <cstdlib>
#include "../../MacroDefinitions.h"


namespace HastlayerOperatingSystem
{

struct InputOutputMemoryCommunicationContext
{
	unsigned int ConnectionId; // Identifies the TCP connection.
	byte State; // Communication state of the TCP connection.
	struct tcp_pcb *ControlBlock; // TCP control block for the lwIP.
	struct pbuf *Buffer; // Buffer read from the packet.
	char Signal; // In case of a special command coming from the PC (eg. execution) the response is in this variable.
	unsigned int InputByteCount; // Amount of bytes coming from the PC without the member ID and the length bytes.
	unsigned int InputByteCountInCurrentPacket; // Amount of bytes coming from the PC in the current packet.
	unsigned int TotalInputByteCount; // Total amount of bytes coming from the PC (including member ID and length bytes).
	int MemberId; // Member ID for the HAST IP.
	unsigned int ReceivedByteCounter; // Amount of bytes received since the connection has established.
	unsigned int CurrentMemoryBaseAddressOffset; // Offset for writing or reading the bytes in the Hastlayer input/output area of the memory.
	int CurrentPayloadOffset; // Offset for reading the bytes from the current packet's buffer.
	unsigned int OutputByteCount; // Amount of bytes sending back to the PC without the execution time and the length bytes.
	unsigned int TotalOutputByteCount; // Total amount of bytes sending back to the PC (including the execution and length bytes).
	unsigned int RemainingOutputByteCount; // Remaining amount of bytes to send back to the PC.
	unsigned int EnqueuedByteCount; // Amount of bytes enqueued currently in the sending buffer.
	unsigned int EnqueuedByteCountForOutputBytes; // Amount of bytes enqueued to send for only the first segment and without the execution time and length bytes.
	unsigned int CurrentSendingBufferSize; // Storing sending buffer size in some point of the sending algorithm.
	unsigned int SentByteCount; // Amount of bytes already sent from the sending buffer.
};


class InputOutputMemoryTcpAcceptCallbackProvider : public AcceptTcpConnectionCallbackProviderBase
{
public:

	/**
	 * Callback for accepting TCP connection requests coming from the Hastlayer host PC.
	 */
	tcp_accept_fn GetCallback();

	/**
	 * Returns true if there is an active communication process with the Hastlayer host PC.
	 */
	static bool IsCommunicationActive();
};

} /* namespace HastlayerOperatingSystem */

#endif /* INPUTOUTPUTMEMORYTCPACCEPTCALLBACKPROVIDER_H_ */
