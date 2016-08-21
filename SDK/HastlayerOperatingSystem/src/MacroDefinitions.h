// Communication channels.
// COMMUNICATION_CHANNEL should be defined in the project's symbol settings with a value of one below.
#define SERIAL 0 // Default communication channel. Also used when the channel is not defined.
#define ETHERNET 1


// Helper for creating if block.
#define IF(statement, operation) if (statement) { operation }


// Debug macro definitions.
// HASTLAYER_DEBUG should be defined in the project's symbol settings with a value of one below.
// On how to read these messages see: https://forums.xilinx.com/t5/Embedded-Development-Tools/How-to-use-xil-printf-in-microblaze/td-p/109916
#define HASTLAYER_DEBUG_LEVEL_INFORMATION 3
#define HASTLAYER_DEBUG_LEVEL_WARNING 2
#define HASTLAYER_DEBUG_LEVEL_ERROR 1
#define HASTLAYER_DEBUG_LEVEL_OFF 0

#ifdef HASTLAYER_DEBUG
	#include "xil_printf.h"

	#define HASTLAYER_DEBUG_WRITE(debugText, ...) xil_printf(debugText "\n", __VA_ARGS__);
	#define HASTLAYER_DEBUG_WRITE_IF(statement, debugText, ...) IF(statement, HASTLAYER_DEBUG_WRITE(debugText, __VA_ARGS__))
#endif

#if HASTLAYER_DEBUG >= HASTLAYER_DEBUG_LEVEL_INFORMATION
	#define HASTLAYER_DEBUG_INFORMATION(debugText, ...) HASTLAYER_DEBUG_WRITE("[INFORMATION]: " debugText, __VA_ARGS__)
	#define HASTLAYER_DEBUG_INFORMATION_IF(statement, debugText, ...) IF(statement, HASTLAYER_DEBUG_INFORMATION(debugText, __VA_ARGS__))
#else
	#define HASTLAYER_DEBUG_INFORMATION(debugText, ...)
	#define HASTLAYER_DEBUG_INFORMATION_IF(statement, debugText, ...)
#endif

#if HASTLAYER_DEBUG >= HASTLAYER_DEBUG_LEVEL_WARNING
	#define HASTLAYER_DEBUG_WARNING(debugText, ...) HASTLAYER_DEBUG_WRITE("[WARNING]: " debugText, __VA_ARGS__)
	#define HASTLAYER_DEBUG_WARNING_IF(statement, debugText, ...) IF(statement, HASTLAYER_DEBUG_WARNING(debugText, __VA_ARGS__))
#else
	#define HASTLAYER_DEBUG_WARNING(debugText, ...)
	#define HASTLAYER_DEBUG_WARNING_IF(statement, debugText, ...)
#endif

#if HASTLAYER_DEBUG >= HASTLAYER_DEBUG_LEVEL_ERROR
	#define HASTLAYER_DEBUG_ERROR(debugText, ...) HASTLAYER_DEBUG_WRITE("[ERROR]: " debugText, __VA_ARGS__)
	#define HASTLAYER_DEBUG_ERROR_IF(statement, debugText, ...) IF(statement, HASTLAYER_DEBUG_ERROR(debugText, __VA_ARGS__))
#else
	#define HASTLAYER_DEBUG_ERROR(debugText, ...)
	#define HASTLAYER_DEBUG_ERROR_IF(statement, debugText, ...)
#endif
