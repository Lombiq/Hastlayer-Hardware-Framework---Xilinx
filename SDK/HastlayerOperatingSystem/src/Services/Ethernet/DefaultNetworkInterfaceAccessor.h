#ifndef DEFAULTNETWORKINTERFACEACCESSOR_H_
#define DEFAULTNETWORKINTERFACEACCESSOR_H_

#include "netif/xadapter.h"


namespace HastlayerOperatingSystem
{

class DefaultNetworkInterfaceAccessor
{
public:

	/**
	 * Returns with the default network interface object.
	 */
	static netif* GetDefaultNetworkInterface();

	/**
	 * Sets the default network interface.
	 */
	static void SetDefaultNetworkInterface(netif* networkInterface);
};

} /* namespace HastlayerOperatingSystem */

#endif /* DEFAULTNETWORKINTERFACEACCESSOR_H_ */
