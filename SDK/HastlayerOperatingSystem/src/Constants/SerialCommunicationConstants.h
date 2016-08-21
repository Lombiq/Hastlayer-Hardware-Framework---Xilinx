#ifndef SERIALCOMMUNICATIONCONSTANTS_H_
#define SERIALCOMMUNICATIONCONSTANTS_H_

namespace HastlayerOperatingSystem
{

class SerialCommunicationConstants
{
public:
	class Signals
	{
	public:
		static const char Ping = 'p';
		static const char Ready = 'r';
	};
};

} /* namespace HastlayerOperatingSystem */

#endif /* SERIALCOMMUNICATIONCONSTANTS_H_ */
