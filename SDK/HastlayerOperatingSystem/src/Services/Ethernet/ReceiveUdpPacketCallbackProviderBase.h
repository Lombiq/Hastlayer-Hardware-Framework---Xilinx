#ifndef RECEIVEUDPPACKETCALLBACKPROVIDERBASE_H_
#define RECEIVEUDPPACKETCALLBACKPROVIDERBASE_H_

#include "lwip/udp.h"


namespace HastlayerOperatingSystem
{

class ReceiveUdpPacketCallbackProviderBase
{
public:

	/**
	 * Abstract callback for receiving UDP packets.
	 */
	virtual udp_recv_fn GetCallback() = 0;
};

} /* namespace HastlayerOperatingSystem */

#endif /* RECEIVEUDPPACKETCALLBACKPROVIDERBASE_H_ */
