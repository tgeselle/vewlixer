; Code in this file will only be run for the emulator whose name matches the filename of this file and whose system name matches the folder name this file is located in
; Do not change the line with the class declaration! The class name must always be EmulatorUserFunction and extend UserFunction
; This is just a sample file, you only need to implement the methods you will use the others can be deleted

class EmulatorUserFunction extends UserFunction {

	; Use this function to define any code you want to run on initialization
	InitUserFeatures() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you want to run in every module on start
	StartUserFeatures() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you may need to stop or clean up in every module on exit
	StopUserFeatures() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you want to run before Pause starts
	StartPauseUserFeatures() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you may need to stop or clean up after Pause ends
	StopPauseUserFeatures() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; These functions can be used to run custom code at certain points in each module

	; This function gets ran right before the primaryExe
	PreLaunch() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This function gets ran right after the primaryExe
	PostLaunch() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This function gets ran right after FadeInExit(), after the emulator is loaded
	PostLoad() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This function gets ran after the module thread ends and before RL exits
	PostExit() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This method gets ran right before Bezel is draw on the screen
	PreBezelDraw() {
		Global dbName
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

}

