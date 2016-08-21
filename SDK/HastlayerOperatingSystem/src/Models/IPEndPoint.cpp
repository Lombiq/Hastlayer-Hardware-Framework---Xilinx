#include "IpEndpoint.h"


namespace HastlayerOperatingSystem
{

IpEndpoint::IpEndpoint(byte segment1, byte segment2, byte segment3, byte segment4, int port)
{
	IP4_ADDR(IpAddress, segment1, segment2, segment3, segment4);
	Port = port;
}

IpEndpoint::IpEndpoint(ip_addr* address, int port)
{
	IpAddress = address;
	Port = port;
}

} /* namespace HastlayerOperatingSystem */
