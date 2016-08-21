#ifndef VALUECONVERTERS_H_
#define VALUECONVERTERS_H_

#include "../TypeDefinitions.h"


namespace HastlayerOperatingSystem
{

class ValueConverters
{
public:
	/**
	 * Swaps the 4 bytes at the given integer address and returns with the newly generated integer.
	 */
	static int ReorderBytes(int* address);
};

} /* namespace HastlayerOperatingSystem */

#endif /* VALUECONVERTERS_H_ */
