MCRC := "B5C09C30"
MVersion := "1.1.1"

; Instantiated by creating the Emulator instance first:
; emulator := new Emulator(fullFilePath)
class Emulator extends Process
{
	;vars
	; inherits all vars from Process class

	__New(fullFilePath)
	{
		Global skipChecks
		RLLog.Trace(A_ThisFunc . " - Creating new emulator object for: """ . fullFilePath . """")
		If (skipChecks = "Rom and Emu" && (fullFilePath = "\" || fullFilePath = ""))
			ScriptError(A_ThisFunc . " - SkipChecks is set to """ . skipChecks . """ so an emulator cannot be created to instantiate this class. Please turn SkipChecks off or use a different setting to continue.")
		If (fullFilePath = "\" || fullFilePath = "")
			ScriptError(A_ThisFunc . " - fullFilePath parameter cannot be blank or must be a valid path to instantiate this class.")
		base.__New(fullFilePath)	; extends to use super class constructor so all Process methods can be used directly
	}

	Run(params:="",options:=0,inputBlocker:=1,bypassCmdWindow:=0,disableLogging:=0,wrapQuotes:="",workingFolder:="") {
		CustomFunction.PreLaunch()
		base.Run(params,options,inputBlocker,bypassCmdWindow,disableLogging,wrapQuotes,workingFolder)
		CustomFunction.PostLaunch()
	}
}
