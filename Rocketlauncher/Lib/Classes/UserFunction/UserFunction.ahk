MCRC := "B43D310C"
MVersion := "1.0.0"

; Code in this file will always be run regardless of the system or game being launched

class UserFunction 
{

	; Use this function to define any code you want to run on initialization
	InitUserFeatures() {
	}

	; Use this function to define any code you want to run in every module on start
	StartUserFeatures() {
	}

	; Use this function to define any code you may need to stop or clean up in every module on exit
	StopUserFeatures() {
	}

	; Use this function to define any code you want to run before Pause starts
	StartPauseUserFeatures() {
	}

	; Use this function to define any code you may need to stop or clean up after Pause ends
	StopPauseUserFeatures() {
	}

	; These functions can be used to run custom code at certain points in each module

	; This function gets ran right before the primaryExe
	PreLaunch() {
	}

	; This function gets ran right after the primaryExe
	PostLaunch() {
	}

	; This function gets ran right after FadeInExit(), after the emulator is loaded
	PostLoad() {
	}

	; This function gets ran after the module thread ends and before RL exits
	PostExit() {
	}

	; This method gets ran right before Bezel is draw on the screen
	PreBezelDraw() {
	}

}
