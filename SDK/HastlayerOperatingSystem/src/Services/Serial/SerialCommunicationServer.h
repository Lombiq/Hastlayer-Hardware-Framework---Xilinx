#ifndef SERIALCOMMUNICATIONSERVICE_H_
#define SERIALCOMMUNICATIONSERVICE_H_

#include "../../Constants/CommandTypes.h"
#include "../../Constants/SerialCommunicationConstants.h"
#include "../MemoryManager.h"
#include "../RegisterManager.h"
#include "UartManager.h"
#include "../../Helpers/ValueConverters.h"


namespace HastlayerOperatingSystem
{

class SerialCommunicationServer
{
public:

	/**
	 * Starts the serial communication server to listen to messages coming from PC.
	 */
	static void StartSerialCommunicationServer();
};

} /* namespace HastlayerOperatingSystem */

#endif /* SERIALCOMMUNICATIONSERVICE_H_ */
