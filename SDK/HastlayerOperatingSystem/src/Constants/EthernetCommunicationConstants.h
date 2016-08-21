#ifndef ETHERNETCOMMUNICATIONCONSTANTS_H_
#define ETHERNETCOMMUNICATIONCONSTANTS_H_

#include "../TypeDefinitions.h"
#include "netif/xadapter.h"


namespace HastlayerOperatingSystem
{

class EthernetCommunicationConstants
{
public:
	class Signals
	{
	public:
		static const char Busy = 'b';
		static const char Ready = 'r';
	};

	class StartTcpListenerReturnCodes
	{
	public:
		static const int Success = 0;
		static const int NetworkInterfaceIsNotInitialized = -1;
		static const int OutOfMemoryWhenCreatingPcb = -2;
		static const int UnableToBindPort = -3;
		static const int OutOfMemoryWhileTcpListen = -4;
	};

	class StartUdpListenerReturnCodes
	{
	public:
		static const int Success = 0;
		static const int NetworkInterfaceIsNotInitialized = -1;
		static const int OutOfMemoryWhenCreatingPcb = -2;
		static const int UnableToBindPort = -3;
	};

	class EthernetInitializationReturnCodes
	{
	public:
		static const int Success = 0;
		static const int AddingDefaultNetworkInterfaceFailed = -1;
	};

	class Initialization
	{
	public:
		// The actual values of these arrays are initialized in the EthernetCommunicationConstants.cpp file.
		static const byte* DefaultIpAddress;
		static const byte* DefaultNetmask;
		static const byte* DefaultGateway;
	};

	class CommunicationPorts
	{
	public:
		static const u16_t InputOutputMemoryCommunicationPort = 34000;
		static const u16_t TcpEchoServerCommunicationPort = 34001;
		static const u16_t WhoIsAvailableCommunicationPort = 34050;
		static const u16_t UdpEchoServerCommunicationPort = 34051;
	};

	class TcpCommunicationStates
	{
	public:
		static const byte Undefined = 0;
		static const byte Accepted = 1;
		static const byte ReceivingInput = 2;
		static const byte SendingOutput = 3;
		static const byte Closed = 4;
	};
};

} /* namespace HastlayerOperatingSystem */

#endif /* ETHERNETCOMMUNICATIONCONSTANTS_H_ */
