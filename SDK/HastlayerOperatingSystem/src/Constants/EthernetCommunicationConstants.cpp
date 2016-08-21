#include "EthernetCommunicationConstants.h"


namespace HastlayerOperatingSystem
{
	static const byte DefaultIpAddressData[] = {192, 168, 1, 10};
	const byte* EthernetCommunicationConstants::Initialization::DefaultIpAddress = DefaultIpAddressData;

	static const byte DefaultNetmaskData[] = {255, 255, 255, 0};
	const byte* EthernetCommunicationConstants::Initialization::DefaultNetmask = DefaultNetmaskData;

	static const byte DefaultGatewayData[] = {192, 168, 1, 1};
	const byte* EthernetCommunicationConstants::Initialization::DefaultGateway = DefaultGatewayData;

} /* namespace HastlayerOperatingSystem */
