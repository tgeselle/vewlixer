; Code in this file will only be run for the game whose name matches the filename of this file and whose system name matches the folder name this file is located in
; Do not change the line with the class declaration! The class name must always be GameUserFunction and extend GameFunction
; This is just a sample file, you only need to implement the methods you will use the others can be deleted

class GameUserFunction extends GameFunction {

	; Use this function to define any code you want to run on initialization
	InitUserFeatures() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you want to run in every module on start
	StartUserFeatures() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you may need to stop or clean up in every module on exit
	StopUserFeatures() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you want to run before Pause starts
	StartPauseUserFeatures() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this function to define any code you may need to stop or clean up after Pause ends
	StopPauseUserFeatures() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; These functions can be used to run custom code at certain points in each module

	; This function gets ran right before the primaryExe
	PreLaunch() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This function gets ran right after the primaryExe
	PostLaunch() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This function gets ran right after FadeInExit(), after the emulator is loaded
	PostLoad() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This function gets ran after the module thread ends and before RL exits
	PostExit() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; This method gets ran right before Bezel is draw on the screen
	PreBezelDraw() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	
	; Game Specific Functions

	
	; Use this method to set fullscreen after the game is running (Used by PCLauncher only)
	; Use this function if fullscreen mode can only be set AFTER the game is running
	SetFullscreenPostLaunch(fs) {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this method to set fullscreen before the game is running (Used by PCLauncher only)
	; Use this function if fullscreen mode can be set BEFORE the game is running, if fullscreen mode is set through CLI then this should return the cli switch necessary to run it windowed or fullscreen
	SetFullscreenPreLaunch(fs) {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
		Return ""
	}

	; Use this method to write any code necessary to halt the game so that Pause can be supported (Used by PCLauncher only)
	HaltGame() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

	; Use this method to write any code necessary to restore the game so that Pause can be supported (Used by PCLauncher only)
	RestoreGame() {
		RLLog.Info(A_ThisFunc . " - Starting")
		; INSERT CODE HERE
		RLLog.Info(A_ThisFunc . " - Ending")
	}

}

