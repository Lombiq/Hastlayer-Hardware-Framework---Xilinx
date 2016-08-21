#include "WhoIsAvailableUdpReceiveCallbackProvider.h"


namespace HastlayerOperatingSystem
{

static void WhoIsAvailableUdpReceiveCallback(void *udpArgument, struct udp_pcb *controlBlock, struct pbuf *buffer, struct ip_addr *ipAddress, u16_t port)
{
	// Don't read the packet if we are not in ESTABLISHED state.
    if (buffer != NULL)
    {
    	if (buffer->len > 0 && *(char*)(buffer->payload) == CommandTypes::WhoIsAvailable)
    	{
    		HASTLAYER_DEBUG_INFORMATION("Who is available request has arrived, started to respond (control block: 0x%0X, buffer: 0x%0X).", controlBlock, buffer);

    		bool isAvailable = !InputOutputMemoryTcpAcceptCallbackProvider::IsCommunicationActive();
    		netif* defaultNetworkInterface = DefaultNetworkInterfaceAccessor::GetDefaultNetworkInterface();
    		u16_t activePort = EthernetCommunicationConstants::CommunicationPorts::InputOutputMemoryCommunicationPort;

    	    struct pbuf *answerBuffer;
    	    answerBuffer = pbuf_alloc(PBUF_TRANSPORT, 7, PBUF_RAM);
    	    if (answerBuffer != NULL)
    	    {
    	    	// Build a 7 byte array to send back. These are the following in order:
    	    	// - 1 byte (availability: True/False)
    	    	// - 4 bytes (IP address of the FPGA)
    	    	// - 2 bytes (port of the Hastlayer input/output TCP listener)
    	    	memcpy((answerBuffer->payload), &isAvailable, 1);
    	    	memcpy((answerBuffer->payload + 1), &(defaultNetworkInterface->ip_addr.addr), 4);
    	    	memcpy((answerBuffer->payload + 5), &activePort, 2);

    	    	// Send the availability status and the IP endpoint back to the sender.
    	    	err_t result = udp_sendto(controlBlock, answerBuffer, ipAddress, port);

        		HASTLAYER_DEBUG_INFORMATION_IF(result == ERR_OK, "Response has been successfully sent.", NULL);
        		HASTLAYER_DEBUG_ERROR_IF(result!= ERR_OK, "Failed to send response (error code: %d).", result);

    	    	pbuf_free(answerBuffer);
    	    }

    		HASTLAYER_DEBUG_ERROR_IF(answerBuffer == NULL, "Not enough memory to allocate UDP sender buffer.", NULL);
    	}

        pbuf_free(buffer);
    }
}


udp_recv_fn WhoIsAvailableUdpReceiveCallbackProvider::GetCallback()
{
	 return WhoIsAvailableUdpReceiveCallback;
}

} /* namespace HastlayerOperatingSystem */
