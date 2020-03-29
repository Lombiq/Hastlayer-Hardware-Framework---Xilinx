#ifndef IPENDPOINT_H_
#define IPENDPOINT_H_

#include "../TypeDefinitions.h"
#include "netif/xadapter.h"


namespace HastlayerOperatingSystem
{

class IpEndpoint
{
public:
   ip4_addr* IpAddress;
   int Port;

   IpEndpoint(byte segment1, byte segment2, byte segment3, byte segment4, int port);
   IpEndpoint(ip4_addr* address, int port);
};

} /* namespace HastlayerOperatingSystem */

#endif /* IPENDPOINT_H_ */
