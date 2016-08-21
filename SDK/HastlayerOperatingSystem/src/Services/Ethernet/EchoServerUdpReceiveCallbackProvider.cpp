#include "EchoServerUdpReceiveCallbackProvider.h"


namespace HastlayerOperatingSystem
{

static void UdpEchoServerReceiveCallback(void *udpArgument, struct udp_pcb *controlBlock, struct pbuf *buffer, struct ip_addr *ipAddress, u16_t port)
{
	// Don't read the packet if we are not in ESTABLISHED state.
    if (buffer != NULL)
    {
        // Send the received packet back to the sender.
        udp_sendto(controlBlock, buffer, ipAddress, port);

        pbuf_free(buffer);
    }
}


udp_recv_fn EchoServerUdpReceiveCallbackProvider::GetCallback()
{
	 return UdpEchoServerReceiveCallback;
}

} /* namespace HastlayerOperatingSystem */
