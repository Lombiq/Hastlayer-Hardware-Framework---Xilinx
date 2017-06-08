#include "MemoryManager.h"


namespace HastlayerOperatingSystem
{

volatile unsigned long *memoryBaseAddressPointer = (volatile unsigned long *) DDR_MEMORY_HAST_IP_BASEADDRESS;


void MemoryManager::CopyIntegersToInputOutputArea(byte* startAddress, int byteLength, unsigned int* offset)
{
	int valuesOffset = 0;

	while (byteLength > valuesOffset)
	{
		MemoryManager::CopyIntegerToInputOutputArea(ValueConverters::ReorderBytes((int*)(startAddress + valuesOffset)), offset);
		valuesOffset += 4;
	}
}

void MemoryManager::CopyIntegerToInputOutputArea(int value, unsigned int* offset)
{
	*((int*)MemoryManager::GetInputOutputMemoryBaseAddress() + *offset) = value;
	(*offset)++;
}

void* MemoryManager::GetInputOutputMemoryBaseAddress()
{
	return (void*)memoryBaseAddressPointer;
}

} /* namespace HastlayerOperatingSystem */
