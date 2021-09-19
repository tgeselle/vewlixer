MCRC := "B9F28305"
MVersion := "1.0.0"

; Code in this file will only be run for the game whose name matches the filename of this file and whose system name matches the folder name this file is located in

class GameFunction extends UserFunction {

	; Use this method to set fullscreen after the game is running (Used by PCLauncher only)
	; Use this function if fullscreen mode can only be set AFTER the game is running
	SetFullscreenPostLaunch(fs) {
	}

	; Use this method to set fullscreen before the game is running (Used by PCLauncher only)
	; Use this function if fullscreen mode can be set BEFORE the game is running, if fullscreen mode is set through CLI then this should return the cli switch necessary to run it windowed or fullscreen
	SetFullscreenPreLaunch(fs) {
		Return ""
	}

	; Use this method to write any code necessary to halt the game so that Pause can be supported (Used by PCLauncher only)
	HaltGame() {
	}

	; Use this method to write any code necessary to restore the game so that Pause can be supported (Used by PCLauncher only)
	RestoreGame() {
	}

}

