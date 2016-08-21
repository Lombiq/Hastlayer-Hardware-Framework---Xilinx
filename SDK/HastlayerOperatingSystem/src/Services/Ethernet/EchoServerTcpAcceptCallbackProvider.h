#ifndef ECHOSERVERTCPACCEPTCALLBACKPROVIDER_H_
#define ECHOSERVERTCPACCEPTCALLBACKPROVIDER_H_

#include "AcceptTcpConnectionCallbackProviderBase.h"


namespace HastlayerOperatingSystem
{

class EchoServerTcpAcceptCallbackProvider : public AcceptTcpConnectionCallbackProviderBase
{
public:

	/**
	 * Callback for accepting TCP connection requests to echo back the packets.
	 */
	tcp_accept_fn GetCallback();
};

} /* namespace HastlayerOperatingSystem */

#endif /* ECHOSERVERTCPACCEPTCALLBACKPROVIDER_H_ */
