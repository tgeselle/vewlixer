MCRC := "E3974B3D"
MVersion := "1.0.3"

; Not instantiated, access functions directly
class CustomFunction
{

	; This method gets ran on initialization
	Init()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.InitUserFeatures()
		SystemUserFunction.InitUserFeatures()
		GlobalEmulatorUserFunction.InitUserFeatures()
		EmulatorUserFunction.InitUserFeatures()
		GameUserFunction.InitUserFeatures()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}
	
	; This method gets ran on start of every module
	PreStart()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.StartUserFeatures()
		SystemUserFunction.StartUserFeatures()
		GlobalEmulatorUserFunction.StartUserFeatures()
		EmulatorUserFunction.StartUserFeatures()
		GameUserFunction.StartUserFeatures()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}
	
	; This method gets ran on exit of every module
	PostStop()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.StopUserFeatures()
		SystemUserFunction.StopUserFeatures()
		GlobalEmulatorUserFunction.StopUserFeatures()
		EmulatorUserFunction.StopUserFeatures()
		GameUserFunction.StopUserFeatures()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}
	
	; This method gets ran before Pause starts
	PrePauseStart()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.StartPauseUserFeatures()
		SystemUserFunction.StartPauseUserFeatures()
		GlobalEmulatorUserFunction.StartPauseUserFeatures()
		EmulatorUserFunction.StartPauseUserFeatures()
		GameUserFunction.StartPauseUserFeatures()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}
	
	; This method gets ran after Pause ends
	PostPauseStop()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.StopPauseUserFeatures()
		SystemUserFunction.StopPauseUserFeatures()
		GlobalEmulatorUserFunction.StopPauseUserFeatures()
		EmulatorUserFunction.StopPauseUserFeatures()
		GameUserFunction.StopPauseUserFeatures()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}

	; This method gets ran right before the primaryExe
	PreLaunch()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.PreLaunch()
		SystemUserFunction.PreLaunch()
		GlobalEmulatorUserFunction.PreLaunch()
		EmulatorUserFunction.PreLaunch()
		GameUserFunction.PreLaunch()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}

	; This method gets ran right after the primaryExe
	PostLaunch()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.PostLaunch()
		SystemUserFunction.PostLaunch()
		GlobalEmulatorUserFunction.PostLaunch()
		EmulatorUserFunction.PostLaunch()
		GameUserFunction.PostLaunch()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}

	; This method gets ran right after FadeInExit(), after the emulator is loaded
	PostLoad()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.PostLoad()
		SystemUserFunction.PostLoad()
		GlobalEmulatorUserFunction.PostLoad()
		EmulatorUserFunction.PostLoad()
		GameUserFunction.PostLoad()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}

	; This method gets ran after the module thread ends and before RL exits
	PostExit()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.PostExit()
		SystemUserFunction.PostExit()
		GlobalEmulatorUserFunction.PostExit()
		EmulatorUserFunction.PostExit()
		GameUserFunction.PostExit()
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}
	
	; This method gets ran right before Bezel is draw on the screen
	PreBezelDraw(fs:="false")
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GlobalUserFunction.PreBezelDraw()
		SystemUserFunction.PreBezelDraw()
		GlobalEmulatorUserFunction.PreBezelDraw()
		EmulatorUserFunction.PreBezelDraw()
		GameUserFunction.PreBezelDraw()

		If (BezelEnabled() || fs = "false")
			CustomFunction.SetFullscreenPostLaunch("false")
		Else
			CustomFunction.SetFullscreenPostLaunch(fs)
		RLLog.Trace(A_ThisFunc . " - Ending")
		Return
	}

	; Calls function to set fullscreen after the game is running (Used by PCLauncher only)
	SetFullscreenPostLaunch(fs)
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		RLLog.Trace(A_ThisFunc . " - Setting fullscreen to " . fs)
		GameUserFunction.SetFullscreenPostLaunch(fs)
		RLLog.Trace(A_ThisFunc . " - Ending")
	}
	
	; Calls function to set fullscreen before the game is running (Used by PCLauncher only)
	SetFullscreenPreLaunch(fs)
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		RLLog.Trace(A_ThisFunc . " - Setting fullscreen to " . fs)
		fsCliStr := GameUserFunction.SetFullscreenPreLaunch(fs)
		RLLog.Trace(A_ThisFunc . " - Ending")

		Return fsCliStr
	}
	
	; Calls function to halt game (Called from HideEmu label in PCLauncher)
	HaltGame()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GameUserFunction.HaltGame()
		RLLog.Trace(A_ThisFunc . " - Ending")
	}
	
	; Calls function to halt game (Called from HideEmu label in PCLauncher)
	RestoreGame()
	{
		RLLog.Trace(A_ThisFunc . " - Starting")
		GameUserFunction.RestoreGame()
		RLLog.Trace(A_ThisFunc . " - Ending")
	}
}
