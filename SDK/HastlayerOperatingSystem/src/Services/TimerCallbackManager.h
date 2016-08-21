#ifndef TIMERCALLBACKMANAGER_H_
#define TIMERCALLBACKMANAGER_H_

#include "../Platform.h"


namespace HastlayerOperatingSystem
{

/**
 * A function pointer type that can be supplied as a callback function to the timer interrupt.
 */
typedef void (*TimerCallback)();

class TimerCallbackManager
{
public:

	/**
	 * Sets the callback that will be invoked during the timer interrupt.
	 */
	static void SetTimerCallback(TimerCallback callback);

	/**
	 * Invokes the registered callback.
	 */
	static void InvokeTimerCallback();
};

} /* namespace HastlayerOperatingSystem */

#endif /* TIMERCALLBACKMANAGER_H_ */
