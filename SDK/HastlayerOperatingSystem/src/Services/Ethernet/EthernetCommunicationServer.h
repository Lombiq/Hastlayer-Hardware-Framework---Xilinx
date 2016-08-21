#ifndef ETHERNETCOMMUNICATIONSERVER_H_
#define ETHERNETCOMMUNICATIONSERVER_H_

#include "EthernetManager.h"
#include "AcceptTcpConnectionCallbackProviderBase.h"
#include "EchoServerTcpAcceptCallbackProvider.h"
#include "InputOutputMemoryTcpAcceptCallbackProvider.h"
#include "ReceiveUdpPacketCallbackProviderBase.h"
#include "EchoServerUdpReceiveCallbackProvider.h"
#include "WhoIsAvailableUdpReceiveCallbackProvider.h"
#include "../RegisterManager.h"
#include <cstdlib>
#include "../../MacroDefinitions.h"


namespace HastlayerOperatingSystem
{

class EthernetCommunicationServer
{
public:

	/**
	 * Starts the Ethernet communication server (including TCP and UDP listeners) to listen to messages coming from PC.
	 */
	static void StartEthernetCommunicationServer();
};

} /* namespace HastlayerOperatingSystem */

#endif /* ETHERNETCOMMUNICATIONSERVER_H_ */
