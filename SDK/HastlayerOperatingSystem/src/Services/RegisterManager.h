#ifndef REGISTERMANAGER_H_
#define REGISTERMANAGER_H_

#include "xil_types.h"
#include "../Platform.h"


namespace HastlayerOperatingSystem
{

class RegisterManager
{
public:
	/**
	 * Sets the Member ID in the register.
	 */
	static void SetMemberId(int memberId);

	/**
	 * Sets the Hast_IP start signal.
	 */
	static void SetStartSignal(bool isStarted);

	/**
	 * Gets the finished signal of Hast_IP.
	 */
	static bool GetFinishedSignal();

	/**
	 * Runs the defined algorithm and waits for the finish signal.
	 */
	static void RunAndWait();

	/**
	 * Returns the address of the 64bit number containing the execution time.
	 */
	static long* GetExecutionTimeAddress();

	/**
	 * Returns the address of the 57bit device DNA represented with a 64bit integer.
	 */
	static long* GetDeviceDnaAddress();
};

} /* namespace HastlayerOperatingSystem */

#endif /* REGISTERMANAGER_H_ */
