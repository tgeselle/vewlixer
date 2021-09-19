MCRC := "C77F028"
MVersion := "1.5.3"

; Instantiated by creating the Process instance first:
; process := new Process(fullFilePath)
; process.Params := params
; process.Run()
; PID := process.PID
class Process extends File
{
	;vars
	; inherits all vars from File class and adds these:
	; Params
	; PID
	; ProcessName
	; Suspended		; if 1, process was suspended

	__New(fullFilePath)
	{
		RLLog.Trace(A_ThisFunc . " - Creating new process object for: """ . fullFilePath . """")
		base.__New(fullFilePath)	; extends to use super class constructor so all File methods can be used directly, (ex FileFullPath, FileName, FilePath, etc)
		this.PID := ""
	}

	__Delete()
	{
		this.Params := ""
		this.PID := ""
		this.ProcessName := ""
		this.Suspended := ""
	}

	; Setting force will force the process ID to be refreshed even if this.PID already exists
	GetProcessID(force:="")
	{
		RLLog.Trace(A_ThisFunc)
		If (!this.PID || force){
			Process, Exist, % this.FileName
			this.PID := ErrorLevel
		}
	}

	GetProcessName()
	{
		If (!this.ProcessName && this.PID) {
			WinGet,pName,ProcessName,% "ahk_pid " . this.PID
			this.ProcessName := pName
		}
	}

	GetProcessHandle(log:=1)
	{
		If !(ProcessHandle := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", this.PID)) {
			If log
				RLLog.Trace(A_ThisFunc . " - Process """ . this.ProcessName . " " . this.PID . """ not found")
			Return
		} Else
			Return ProcessHandle
	}
	
	; mode = default uses this.FileName. Set mode to "PID" to use this.PID instead
	Process(cmd,cmdParam:="",mode:="file")	; ProcessName name may not always be the same as this.File, will have to look into this later if it comes up
	{
		RLLog.Info(A_ThisFunc . " - """ . cmd . """ """ . this.FileName . """ " . cmdParam)
		If (cmd != "Wait")	; when Wait is called, process won't exist yet, so no point in trying to get the PID until later
			this.GetProcessID()
		var := If mode = "PID" ? this.PID : this.FileName		; Use either PID or FileName. For some reason AHK returns 0 on pcsx2 on WaitClose if I don't call Process using the var instead of the object
		Process, % cmd, % var, % cmdParam
		errLvl := ErrorLevel
		If (cmd = "WaitClose") {
			RLLog.Debug(A_ThisFunc . " - """ . var . """ returned " . errLvl . " and is now closed. Continuing thread.")
		} Else If (cmd = "Wait") {
			this.GetProcessID()
			If (errLvl = 0)
				RLLog.Error(A_ThisFunc . " - """ . var . """ returned " . errLvl . " and failed to show.")
			Else
				RLLog.Debug(A_ThisFunc . " - """ . var . """ returned " . errLvl . " and is now running")
		}
		Return errLvl
	}

	ProcessClose()
	{
		Return this.Process("Close")
	}

	ProcessWaitClose(waitTimeout:="")
	{
		Return this.Process("WaitClose",waitTimeout)
	}
	ProcessSuspend() {
		this.GetProcessID()
		If PH := this.GetProcessHandle()
		{
			If !this.ProcessName
				this.GetProcessName()
			RLLog.Debug(A_ThisFunc . " -  Suspending Process: " . this.ProcessName . " " . this.PID)
			DllCall("ntdll.dll\NtSuspendProcess", "Int", PH), DllCall("CloseHandle", "Int", PH)
			this.Suspended := 1
			Return 1
		}
		Return
	}

	ProcessResume() {
		this.GetProcessID()
		If ((PH := this.GetProcessHandle()) && this.Suspended)	; must have been suspended previously with ProcessSuspend()
		{
			RLLog.Debug(A_ThisFunc . " -  Resuming Process: " . this.ProcessName . " " . this.PID)
			DllCall("ntdll.dll\NtResumeProcess", "Int", PH), DllCall("CloseHandle", "Int", PH)
			this.Suspended := ""
			Return 1
		}
		Return
	}

	; To disable inputBlocker on a specific Run call, set inputBlocker to 0, or to force it a specified amount of seconds (upto 30), set it to that amount.
	; By default, options will enable all calls of Run() to return errorlevel within the function. However, it will only be returned if errorLevelReporting is true
	; bypassCmdWindow - some apps will never work with the command window, like xpadder. enable this argument on these Run calls so it doesn't get caught here
	Run(params:="",options:=0,inputBlocker:=1,bypassCmdWindow:=0,disableLogging:=0,wrapQuotes:="",workingFolder:="")	; PID should now be in the object and not ByRef in the function call
	{
		Static cmdWindowCount
		Global logShowCommandWindow,logCommandWindow,cmdWindowObj,blockInputTime,blockInputFile,errorLevelReporting
		
		this.Params := (params ? " " . params : "")
		options := If options = 1 ? "useErrorLevel" : options	; enable or disable error level
		If disableLogging
			RLLog.Info(A_ThisFunc . " - Running hidden executable in " . this.FilePath)
		Else
			RLLog.Info(A_ThisFunc . " - Running: " . (If wrapQuotes ? """" : "") . this.FileFullPath . (If wrapQuotes ? """" : "") . this.Params)
		If (blockInputTime && inputBlocker = 1)	; if user set a block time, use the user set length
			blockTime := blockInputTime
		Else If (inputBlocker > 1)	; if module called for a block, use that amount
			blockTime := inputBlocker
		Else	; do not block input
			blockTime := ""
		If blockTime
		{	RLLog.Info(A_ThisFunc . " - Blocking Input for: " . blockTime . " seconds")
			Run, % blockInputFile . A_Space . blockTime
		}
		If !cmdWindowObj
			cmdWindowObj := Object()	; initialize object, this is used so all the command windows can be properly closed on exit
		If (logShowCommandWindow = "true" && !bypassCmdWindow) {
			Run, % ComSpec . " /k", % this.FilePath, % options, PID	; open a command window (cmd.exe), starting in the directory of the target executable
			curErr := ErrorLevel	; store error level immediately
			this.PID := PID
			If (errorLevelReporting = "true")
			{	RLLog.Debug(A_ThisFunc . " - Error Level for " . ComSpec . " reported as: " . curErr)
				errLvl := curErr	; allows the module to handle the error level
			}
			RLLog.Warning(A_ThisFunc . " - Showing Command Window to troubleshoot launching. ProcessID: " . this.PID)

			cmdWindow := new Window(new WindowTitle("","","","",this.PID))	; instantiate command window object
			cmdWindow.Get("ID")
			cmdWindow.WinTitle.PID := ""	; remove PID from future window matches
			cmdWindow.WinTitle.ID := cmdWindow.ID	; inject hwnd ID so future matches use it instead
			
			cmdWindow.Wait()
			cmdWindow.Activate()
			errLvl := cmdWindow.WaitActive(2)
			If errLvl {
				cmdWindow.Set("AlwaysOnTop", "On")
				cmdWindow.Activate()
				errLvl := cmdWindow.WaitActive(2)
				If errLvl
					ScriptError("Could not put focus onto the command window. Please try turning off Fade In if you have it enabled in order to see it")
			}
			this.ProcessName := cmdWindow.Get("ProcessName")	; get the name of the process (which should usually be cmd.exe)
			mapObjects[currentObj,"type"] := "database"
			cmdWindowCount++
			
			cmdWindowObj[cmdWindowCount,"Name"] := this.ProcessName	; store the ProcessName being ran
			cmdWindowObj[cmdWindowCount,"PID"] := this.PID	; store the PID of the application being ran

			If (logCommandWindow = "true")
				KeyUtils.SendInput("{Raw}" . (If wrapQuotes ? """" : "") . this.FileName . (If wrapQuotes ? """" : "") . this.Params . " 1>""" . A_ScriptDir . "\command_" . cmdWindowCount . "_output.log"" 2>""" . A_ScriptDir . "\command_" . cmdWindowCount . "_error.log""")	; send the text to the command window and log the output to file
			Else
				KeyUtils.SendInput("{Raw}" . (If wrapQuotes ? """" : "") . this.FileName . (If wrapQuotes ? """" : "") . this.Params)	; send the text to the command window and run it
			KeyUtils.Send("{Enter}")
		} Else {
			Run, % (If wrapQuotes ? """" : "") . this.FileName . (If wrapQuotes ? """" : "") . this.Params, % (If workingFolder ? workingFolder : this.FilePath), %options%, PID
			curErr := ErrorLevel	; store error level immediately
			this.PID := PID
			If (errorLevelReporting = "true")
			{	RLLog.Debug(A_ThisFunc . " - Error Level for " . this.FileName . this.Params . " reported as: " . curErr)
				errLvl := curErr	; allows the module to handle the error level
			}
		}
		If disableLogging
			RLLog.Debug(A_ThisFunc . " - ""Hidden executable"" Process ID: " . this.PID)
		Else
			RLLog.Debug(A_ThisFunc . " - """ . this.FileName . this.Params . """ Process ID: " . this.PID)
		Return errLvl
	}

	; This allows running a file directly w/o setting the working folder path. Restarting the taskbar requires this method otherwise it opens explorer file manager instead.
	RunDirect(cmd,workingPath:="",options:="",wait:="")
	{
		Global errorLevelReporting
		If wait
			RunWait, % cmd,% workingPath,% options,PID
		Else
			Run, % cmd,% workingPath,% options,PID
		errLvl := ErrorLevel	; store error level immediately
		this.PID := PID
		RLLog.Debug(A_ThisFunc . " - """ . cmd . """ Process ID: " . this.PID . " and ErrorLevel reported as: " . errLvl)
		Return errLvl
	}

	RunWait(params,options:=0,wrapQuotes:="") ;,ByRef outputVarPID="")	; PID should now be in the object and not ByRef in the function call
	{
		Global errorLevelReporting
		this.Params := (params ? " " . params : "")
		options := If options = 1 ? "useErrorLevel" : options	; enable or disable error level
		RLLog.Info(A_ThisFunc . " - Started - running: " . (If wrapQuotes ? """" : "") . this.FilePath . "\" . this.FileName . (If wrapQuotes ? """" : "") . this.Params)
		RunWait, % (If wrapQuotes ? """" : "") . this.FileName . (If wrapQuotes ? """" : "") . this.Params, % this.FilePath, %options%, PID
		errLvl := ErrorLevel	; store error level immediately
		this.PID := PID
		RLLog.Debug(A_ThisFunc . " - """ . this.FileName . this.Params . """ Process ID: " . this.PID . " and ErrorLevel reported as: " . errLvl)
		Return errLvl
	}
}
