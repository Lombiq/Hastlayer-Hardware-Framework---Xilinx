#ifndef MEMORYMANAGER_H_
#define MEMORYMANAGER_H_

#include "xbasic_types.h"
#include "../Helpers/ValueConverters.h"
#include "../Platform.h"


namespace HastlayerOperatingSystem
{

class MemoryManager
{
public:
	/**
	 * Copies integers to the input/output area of memory beginning from the given offset. Offset is being incremented. Note: reverses the bytes before converts them to integer.
	 */
	static void CopyIntegersToInputOutputArea(byte* startAddress, int byteLength, unsigned int* offset);

	/**
	 * Copies an integer to the input/output area of memory beginning from the given offset. Offset is being incremented.
	 */
	static void CopyIntegerToInputOutputArea(int value, unsigned int* offset);

	/**
	 * Returns with the address of the beginning of input/output area of memory.
	 */
	static void* GetInputOutputMemoryBaseAddress();
};

} /* namespace HastlayerOperatingSystem */

#endif /* MEMORYMANAGER_H_ */
