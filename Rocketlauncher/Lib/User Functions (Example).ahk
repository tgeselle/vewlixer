; Use this function to define any code you want to run in every module on start
StartGlobalUserFeatures(){
	Global RLLog,dbName,systemName,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}

; Use this function to define any code you may need to stop or clean up in every module on exit
StopGlobalUserFeatures(){
	Global RLLog,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}

; Use this function to define any code you want to run before Pause starts
StartPauseUserFeatures(){
	Global RLLog,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}

; Use this function to define any code you may need to stop or clean up after Pause ends
StopPauseUserFeatures(){
	Global RLLog,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}

; These functions can be used to run custom code at certain points in each module

; This function gets ran right before the primaryExe
PreLaunch(){
	Global RLLog,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}

; This function gets ran right after the primaryExe
PostLaunch(){
	Global RLLog,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}

; This function gets ran right after FadeInExit(), after the emulator is loaded
PostLoad(){
	Global RLLog,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}

; This function gets ran after the module thread ends and before RL exits
PostExit(){
	Global RLLog,dbName,systemName
	RLLog.Info(A_ThisFunc . " - Starting")
	; INSERT CODE HERE
	RLLog.Info(A_ThisFunc . " - Ending")
}
