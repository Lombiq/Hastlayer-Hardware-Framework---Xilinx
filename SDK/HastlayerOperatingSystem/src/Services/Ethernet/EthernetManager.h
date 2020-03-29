#ifndef ETHERNETMANAGER_H_
#define ETHERNETMANAGER_H_

#include "netif/xadapter.h"
#include "../../Platform.h"
#include "lwip/init.h"
#include "lwip/tcp.h"
#include "../../Constants/EthernetCommunicationConstants.h"
#include "lwip/udp.h"
#include "../../Models/IpEndpoint.h"
#include "AcceptTcpConnectionCallbackProviderBase.h"
#include "ReceiveUdpPacketCallbackProviderBase.h"
#include "DefaultNetworkInterfaceAccessor.h"
#include "../../MacroDefinitions.h"

#if LWIP_DHCP==1
#include "lwip/dhcp.h"
#endif


namespace HastlayerOperatingSystem
{

/**
 * A function pointer type that can be supplied as a callback function for when the finished signal is fired.
 */
typedef void (*FinishedSignalCallback)();

class EthernetManager
{
public:

	/**
	 * Returns true if the network interface has been initialized.
	 */
	static bool IsNetworkInterfaceInitialized();

	/**
	 * Initializes the given Ethernet network interface. Sets default IP address for the FPGA if DHCP is not active.
	 */
	static int Initialize(unsigned char* macAddress, struct netif* networkInterface);

	/**
	 * Starts a TCP listener with a custom callback for accepting connections.
	 * The specified function will be called for accepting connections.
	 */
	static int StartTcpListener(IpEndpoint endpoint, AcceptTcpConnectionCallbackProviderBase* acceptConnectionCallbackProvider);

	/**
	 * Starts an UDP listener with a custom callback for accepting connections.
	 * The specified function will be called for receiving packets.
	 */
	static int StartUdpListener(IpEndpoint endpoint, ReceiveUdpPacketCallbackProviderBase* receivePacketCallbackProvider);

	/**
	 * Starts an infinite loop where the network interface is being watched and specific events are fired.
	 */
	static void WatchNetworkInterface(struct netif* networkInterface);

	/**
	 * Callback for the timer interrupt that handles periodic network-related tasks.
	 */
	static void TimerCallback();

	/**
	 * Sets the callback function that will be invoked when the finished signal is fired next time.
	 */
	static void SetCallbackForNextFinishedSignal(FinishedSignalCallback callback);
};

} /* namespace HastlayerOperatingSystem */

#endif /* ETHERNETMANAGER_H_ */
