#include "TimerCallbackManager.h"


namespace HastlayerOperatingSystem
{

static TimerCallback _callback;


void TimerCallbackManager::SetTimerCallback(TimerCallback callback)
{
	_callback = callback;
}

void TimerCallbackManager::InvokeTimerCallback()
{
	_callback();
}

} /* namespace HastlayerOperatingSystem */
