#include "EthernetManager.h"
#include "../RegisterManager.h"
#include "../TimerCallbackManager.h"

#if LWIP_DHCP==1
extern volatile int DhcpTimeoutCounter;
#endif


namespace HastlayerOperatingSystem
{

static bool _networkInterfaceIsInitialized = false;
static FinishedSignalCallback _finishedSignalCallback = NULL;


void SetDefaultIpAddresses(struct ip_addr *ipAddress, struct ip_addr *netmask, struct ip_addr *gateway)
{
	IP4_ADDR(ipAddress,
			EthernetCommunicationConstants::Initialization::DefaultIpAddress[0],
			EthernetCommunicationConstants::Initialization::DefaultIpAddress[1],
			EthernetCommunicationConstants::Initialization::DefaultIpAddress[2],
			EthernetCommunicationConstants::Initialization::DefaultIpAddress[3]);
	IP4_ADDR(netmask,
			EthernetCommunicationConstants::Initialization::DefaultNetmask[0],
			EthernetCommunicationConstants::Initialization::DefaultNetmask[1],
			EthernetCommunicationConstants::Initialization::DefaultNetmask[2],
			EthernetCommunicationConstants::Initialization::DefaultNetmask[3]);
	IP4_ADDR(gateway,
			EthernetCommunicationConstants::Initialization::DefaultGateway[0],
			EthernetCommunicationConstants::Initialization::DefaultGateway[1],
			EthernetCommunicationConstants::Initialization::DefaultGateway[2],
			EthernetCommunicationConstants::Initialization::DefaultGateway[3]);
}


int EthernetManager::Initialize(unsigned char* macAddress, struct netif* networkInterface)
{
	HASTLAYER_DEBUG_INFORMATION("Initializing network interface.", NULL);

	if (_networkInterfaceIsInitialized)
	{
		HASTLAYER_DEBUG_WARNING("Network interface has already been initalized.", NULL);
		return EthernetCommunicationConstants::EthernetInitializationReturnCodes::Success;
	}

	lwip_init();

	struct ip_addr ipAddress, netmask, gateway;

#if (LWIP_DHCP==1)
	ipAddress.addr = 0;
	netmask.addr = 0;
	gateway.addr = 0;
#else
	HASTLAYER_DEBUG_INFORMATION("DHCP is not active, setting default IP addresses.", NULL);
	SetDefaultIpAddresses(&ipAddress, &netmask, &gateway);
#endif

  	// Add network interface to the netif_list, and set it as default.
	if (!xemac_add(networkInterface, &ipAddress, &netmask, &gateway, macAddress, PLATFORM_EMAC_BASEADDR))
	{
		HASTLAYER_DEBUG_ERROR("Failed to add network interface to the list.", NULL);
		return EthernetCommunicationConstants::EthernetInitializationReturnCodes::AddingDefaultNetworkInterfaceFailed;
	}

	netif_set_default(networkInterface);

	Platform::EnableInterrupts();

	netif_set_up(networkInterface);

#if (LWIP_DHCP==1)
	HASTLAYER_DEBUG_INFORMATION("Acquiring IP address from DHCP server.", NULL);

	dhcp_start(networkInterface);

	DhcpTimeoutCounter = 60;

	while (networkInterface->ip_addr.addr == 0 && DhcpTimeoutCounter > 0)
	{
		xemacif_input(networkInterface);
	}

	// Setting IP address wasn't successful so we set the default IP address.
	if (DhcpTimeoutCounter <= 0 && networkInterface->ip_addr.addr == 0)
	{
		HASTLAYER_DEBUG_WARNING("Acquiring IP address has failed. Setting default IP addresses.", NULL);

		SetDefaultIpAddresses(&networkInterface->ip_addr, &networkInterface->netmask, &networkInterface->gw);
	}
#endif

	HASTLAYER_DEBUG_INFORMATION("Network interface has been successfully initialized. Setting it as default.", NULL);
	HASTLAYER_DEBUG_INFORMATION("IP Address: %d.%d.%d.%d",
			ip4_addr1(&networkInterface->ip_addr),
			ip4_addr2(&networkInterface->ip_addr),
			ip4_addr3(&networkInterface->ip_addr),
			ip4_addr4(&networkInterface->ip_addr));
	HASTLAYER_DEBUG_INFORMATION("Netmask: %d.%d.%d.%d",
			ip4_addr1(&networkInterface->netmask),
			ip4_addr2(&networkInterface->netmask),
			ip4_addr3(&networkInterface->netmask),
			ip4_addr4(&networkInterface->netmask));
	HASTLAYER_DEBUG_INFORMATION("Gateway: %d.%d.%d.%d",
			ip4_addr1(&networkInterface->gw),
			ip4_addr2(&networkInterface->gw),
			ip4_addr3(&networkInterface->gw),
			ip4_addr4(&networkInterface->gw));

	_networkInterfaceIsInitialized = true;

	DefaultNetworkInterfaceAccessor::SetDefaultNetworkInterface(networkInterface);

	return EthernetCommunicationConstants::EthernetInitializationReturnCodes::Success;
}

int EthernetManager::StartTcpListener(IpEndpoint endpoint, AcceptTcpConnectionCallbackProviderBase* acceptConnectionCallbackProvider)
{
	HASTLAYER_DEBUG_INFORMATION("Starting TCP listener.", NULL);
	// Check if the network is initialized.
	if (!_networkInterfaceIsInitialized)
	{
		HASTLAYER_DEBUG_ERROR("Network interface has not been initialized yet.", NULL);
		return EthernetCommunicationConstants::StartTcpListenerReturnCodes::NetworkInterfaceIsNotInitialized;
	}

	// Create new TCP PCB.
	struct tcp_pcb *newControlBlock = tcp_new();
	if (!newControlBlock)
	{
		HASTLAYER_DEBUG_ERROR("Out of memory when creating TCP control block.", NULL);
		return EthernetCommunicationConstants::StartTcpListenerReturnCodes::OutOfMemoryWhenCreatingPcb;
	}

	// Bind to the specified IP address and port.
	err_t result = tcp_bind(newControlBlock, endpoint.IpAddress, endpoint.Port);
	if (result != ERR_OK)
	{
		HASTLAYER_DEBUG_ERROR("Unable to bind the given endpoint to the control block (error code: %d).", result);
		return EthernetCommunicationConstants::StartTcpListenerReturnCodes::UnableToBindPort;
	}

	// We don't set any arguments to the accept callback function.
	tcp_arg(newControlBlock, NULL);

	// Start listening for connections.
	newControlBlock = tcp_listen(newControlBlock);
	if (!newControlBlock)
	{
		HASTLAYER_DEBUG_ERROR("Out of memory while starting TCP listener.", NULL);
		return EthernetCommunicationConstants::StartTcpListenerReturnCodes::OutOfMemoryWhileTcpListen;
	}

	tcp_accept_fn callback = acceptConnectionCallbackProvider->GetCallback();
	// Specify callback to use for incoming connections.
	tcp_accept(newControlBlock, callback);

	HASTLAYER_DEBUG_INFORMATION("TCP listener has been started successfully.", NULL);

	return EthernetCommunicationConstants::StartTcpListenerReturnCodes::Success;
}

int EthernetManager::StartUdpListener(IpEndpoint endpoint, ReceiveUdpPacketCallbackProviderBase* receivePacketCallbackProvider)
{
	HASTLAYER_DEBUG_INFORMATION("Starting UDP listener.", NULL);

	// Check if the network is initialized.
	if (!_networkInterfaceIsInitialized)
	{
		HASTLAYER_DEBUG_ERROR("Network interface has not been initialized yet.", NULL);
		return EthernetCommunicationConstants::StartUdpListenerReturnCodes::NetworkInterfaceIsNotInitialized;
	}

	// Create new UDP PCB.
    struct udp_pcb *newControlBlock = udp_new();
	if (!newControlBlock)
	{
		HASTLAYER_DEBUG_ERROR("Out of memory when creating UDP control block.", NULL);
		return EthernetCommunicationConstants::StartUdpListenerReturnCodes::OutOfMemoryWhenCreatingPcb;
	}

	err_t result = udp_bind(newControlBlock, endpoint.IpAddress, endpoint.Port);
    if (result != ERR_OK)
    {
		HASTLAYER_DEBUG_ERROR("Unable to bind the given endpoint to the control block (error code: %d).", result);
		return EthernetCommunicationConstants::StartUdpListenerReturnCodes::UnableToBindPort;
    }

	// Specify callback to use for incoming UDP packets. Also use a pointer as a connection ID where the address is the actual ID.
	static int udpConnectionId = 1;
	udp_recv_fn callback = receivePacketCallbackProvider->GetCallback();
    udp_recv(newControlBlock, callback, (void*)udpConnectionId);
    udpConnectionId++;

	HASTLAYER_DEBUG_INFORMATION("TCP listener has been started successfully.", NULL);

	return EthernetCommunicationConstants::StartUdpListenerReturnCodes::Success;
}

void EthernetManager::WatchNetworkInterface(struct netif* networkInterface)
{
	// Receive and process packets.
	// We need to call tcp_fasttmr & tcp_slowtmr at intervals specified by lwIP, see:
	// https://lists.nongnu.org/archive/html/lwip-users/2008-02/msg00010.html
	// tcp_fasttmr() should be called every 250ms, tcp_slowtmr() every 500ms. tcp_tmr() will call both.
	// It is not important that the timing is absolutely accurate, here it's much faster.
	while (true)
	{
		if (_finishedSignalCallback != NULL && RegisterManager::GetFinishedSignal())
		{
			_finishedSignalCallback();
			_finishedSignalCallback = NULL;
		}

		tcp_tmr();

		xemacif_input(networkInterface);
	}
}

void EthernetManager::TimerCallback()
{
	// The DHCP-related parts here shouldn't be deactivated once DHCP is set up since they're also needed to renew the
	// lease on the address. See: https://lists.nongnu.org/archive/html/lwip-users/2004-08/msg00044.html

	static int odd = 1;

#if LWIP_DHCP==1
    static int DhcpTimer = 0;
#endif

	odd = !odd;

	if (odd)
	{
#if LWIP_DHCP==1
		DhcpTimer++;
		DhcpTimeoutCounter--;

		dhcp_fine_tmr();

		if (DhcpTimer >= 120)
		{
			dhcp_coarse_tmr();
			DhcpTimer = 0;
		}
#endif
	}
}

void EthernetManager::SetCallbackForNextFinishedSignal(FinishedSignalCallback callback)
{
	_finishedSignalCallback = callback;
}


} /* namespace HastlayerOperatingSystem */
