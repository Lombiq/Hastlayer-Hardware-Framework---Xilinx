#include "ValueConverters.h"


namespace HastlayerOperatingSystem
{

int ValueConverters::ReorderBytes(int *address)
{
	int result = 0;
	byte* startAddress = (byte*)address;

	result = (result << 8) + *(startAddress + 3);
	result = (result << 8) + *(startAddress + 2);
	result = (result << 8) + *(startAddress + 1);
	result = (result << 8) + *startAddress;

	return result;
}

} /* namespace HastlayerOperatingSystem */
