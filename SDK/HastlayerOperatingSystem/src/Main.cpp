#include "MacroDefinitions.h"
#include "Platform.h"
// You can set COMMUNICATION_CHANNEL directive in the Xilinx SDK under compiler symbols too.
// Right click on the project, C/C++ Build Settings, under the  Tool Settings tab select MicroBlaze g++ compiler and
// under it Symbols. There you'll be able to change the directives.
#if COMMUNICATION_CHANNEL==ETHERNET
#include "Services/Ethernet/EthernetCommunicationServer.h"
#else
#include "Services/Serial/SerialCommunicationServer.h"
#endif

using namespace HastlayerOperatingSystem;

int main()
{
#if COMMUNICATION_CHANNEL==ETHERNET
	CommunicationChannel communicationChannel = Ethernet;
#else
	CommunicationChannel communicationChannel = Serial;
#endif

	// Initializing platform.
	Platform::InitializePlatform(communicationChannel);

#if COMMUNICATION_CHANNEL==ETHERNET
	// Starts Ethernet communication server. It blocks the thread by running an infinite loop.
	EthernetCommunicationServer::StartEthernetCommunicationServer();
#else
	// Starts serial communication server. It blocks the thread by running an infinite loop.
	SerialCommunicationServer::StartSerialCommunicationServer();
#endif

	Platform::CleanupPlatform();

	return 0;
}
