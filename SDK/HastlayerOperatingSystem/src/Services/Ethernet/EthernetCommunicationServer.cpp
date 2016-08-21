#include "EthernetCommunicationServer.h"
#include "../TimerCallbackManager.h"

namespace HastlayerOperatingSystem
{

// This source code is coming from https://sites.google.com/site/murmurhash/
// and was modified to fit our coding conventions.
unsigned int MurmurHash2(const byte* key, int length, unsigned int seed)
{
	// "m" and "r" are mixing constants generated offline.
	// They're not really "magic", they just happen to work well.
	const unsigned int m = 0x5bd1e995;
	const int r = 24;

	// Initialize the hash to a "random" value.
	unsigned int hash = seed ^ length;

	// Mix 4 bytes at a time into the hash.
	const unsigned char* data = (const unsigned char*)key;
	while(length >= 4)
	{
		unsigned int k = *(unsigned int*)data;

		k *= m;
		k ^= k >> r;
		k *= m;

		hash *= m;
		hash ^= k;

		data += 4;
		length -= 4;
	}

	// Handle the last few bytes of the input array.
	switch (length)
	{
	case 3: hash ^= data[2] << 16;
	case 2: hash ^= data[1] << 8;
	case 1: hash ^= data[0];
	        hash *= m;
	};

	// Do a few final mixes of the hash to ensure the last few
	// bytes are well-incorporated.
	hash ^= hash >> 13;
	hash *= m;
	hash ^= hash >> 15;

	return hash;
}


void EthernetCommunicationServer::StartEthernetCommunicationServer()
{
	// The Ethernet communication implementation uses the lwIP library's raw API, see:
	// http://lwip.wikia.com/wiki/Raw/TCP and http://www.ecoscentric.com/ecospro/doc/html/ref/lwip-basics.html

	TimerCallbackManager::SetTimerCallback(&EthernetManager::TimerCallback);

	HASTLAYER_DEBUG_INFORMATION("Starting Ethernet communication server.", NULL);

	static struct netif* defaultNetworkInterface = (netif*)malloc(sizeof(netif));

	// We are generating MAC address from the device DNA.
	long* deviceDna = RegisterManager::GetDeviceDnaAddress();

	// Because device DNA is 57 bit (64 bit is allocated for it) and MAC address is 48 bit
	// we need to hash the DNA. Murmur2 hashing algorithm seems to fit our requirements of size
	// and collision resistance. It creates a 32 bit hash so the last 16 bit of the MAC address
	// is coming from the last 16 bit of the device DNA.
	// Using hashing algorithm instead of using the last 48 bits of the device DNA is because
	// we don't know if the DNA is randomly generated or just a sequential ID - that case
	// would be perfect to use its last bits directly as the MAC address.
	int hashedDeviceDna = MurmurHash2((byte*)deviceDna, 8, 0);

	unsigned char* macAddress = (unsigned char*)malloc(6);
	int* deviceDnaLastBytes = ((int*)deviceDna) + 1;
	macAddress[0] = hashedDeviceDna;
	macAddress[1] = (hashedDeviceDna >> 8);
	macAddress[2] = (hashedDeviceDna >> 16);
	macAddress[3] = (hashedDeviceDna >> 24);
	macAddress[4] = (*deviceDnaLastBytes >> 9);
	macAddress[5] = (*deviceDnaLastBytes >> 17);

	HASTLAYER_DEBUG_INFORMATION("MAC address has been generated: %02X-%02X-%02X-%02X-%02X-%02X",
			macAddress[0],
			macAddress[1],
			macAddress[2],
			macAddress[3],
			macAddress[4],
			macAddress[5]);

	EthernetManager::Initialize(macAddress, defaultNetworkInterface);

	// It will activate a TCP listener on the 34000 port to receive input/output memory from the host PC.
	IpEndpoint inputOutputListenerEndpoint(IP_ADDR_ANY, EthernetCommunicationConstants::CommunicationPorts::InputOutputMemoryCommunicationPort);
	InputOutputMemoryTcpAcceptCallbackProvider inputOutputMemoryCallbackProvider;
	EthernetManager::StartTcpListener(inputOutputListenerEndpoint, &inputOutputMemoryCallbackProvider);

	// It will activate the WhoIsAvailable server on the 34050 port to respond these broadcast messages.
	IpEndpoint whoIsAvailableEndpoint(IP_ADDR_ANY, EthernetCommunicationConstants::CommunicationPorts::WhoIsAvailableCommunicationPort);
	WhoIsAvailableUdpReceiveCallbackProvider whoIsAvailableCallbackProvider;
	EthernetManager::StartUdpListener(whoIsAvailableEndpoint, &whoIsAvailableCallbackProvider);

	// If you want to test TCP communication with an ECHO server then uncomment the lines below. It will use the port 34001.
	//IpEndPoint tcpEchoServerEndpoint(IP_ADDR_ANY, EthernetCommunicationConstants::CommunicationPorts::TcpEchoServerCommunicationPort);
	//EchoServerTcpAcceptCallbackProvider tcpEchoServerCallbackProvider;
	//EthernetManager::StartTcpListener(tcpEchoServerEndpoint, &tcpEchoServerCallbackProvider);


	// If you want to test UDP communication with an ECHO server then uncomment the lines below. It will use the port 34051.
	//IpEndpoint udpEchoServerEndpoint(IP_ADDR_ANY, EthernetCommunicationConstants::CommunicationPorts::UdpEchoServerCommunicationPort);
	//EchoServerUdpReceiveCallbackProvider udpEchoServerCallbackProvider;
	//EthernetManager::StartUdpListener(udpEchoServerEndpoint, &udpEchoServerCallbackProvider);


	// Now starting to watch the network interface. It blocks the thread by running an infinite loop.
	EthernetManager::WatchNetworkInterface(defaultNetworkInterface);
}

} /* namespace HastlayerOperatingSystem */
