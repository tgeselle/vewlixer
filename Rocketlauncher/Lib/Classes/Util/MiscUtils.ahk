MCRC := "B64C6278"
MVersion := "1.1.3"

; Not instantiated, access functions directly
class MiscUtils
{
	DetectHiddenWindows(mode:="On",log:=1)
	{
		If (mode != A_DetectHiddenWindows) {
			DetectHiddenWindows, % mode
			If log
				RLLog.Trace(A_ThisFunc . " - Mode changed to """ . mode . """")
		}
		Return
	}

	GetActiveWindowStatus(){
		dWin := A_DetectHiddenWindows	; store current value to return later
		If (dWin != "On") {
			RLLog.Debug(A_ThisFunc . " - Turning on DetectHiddenWindows window as it's needed to get window Stats")
			this.DetectHiddenWindows("On")
		}
		activeWinHWND := WinExist("A")
		If activeWinHWND {	; do not attempt to instantiate a window if there was a problem retrieving an active hwnd ID
			ActiveWindow := new Window(new WindowTitle("","","",activeWinHWND))
			ActiveWindow.Get("ProcessPath",0)
			ActiveWindow.Get("PID",0)
			ActiveWindow.Get("MinMax",0)
			ActiveWindowClass := ActiveWindow.GetClass("",0)
			ActiveWindowTitle := ActiveWindow.GetTitle("",0)
			ActiveWindow.GetPos(X,Y,W,H)
			RLLog.Debug(A_ThisFunc . " - Title: " . ActiveWindowTitle . " | Class: " . ActiveWindowClass . " | State: " . ActiveWindow.MinMax . " | X: " . X . " | Y: " . Y . " | Width: " . W . " | Height: " . H . " | Window HWND: " . activeWinHWND . " | Process ID: " . ActiveWindow.PID . " | Process Path: " . ActiveWindow.ProcessPath)
		} Else
			RLLog.Warning(A_ThisFunc . " - There was a problem retrieving the active HWND ID")
		
		If (dWin != A_DetectHiddenWindows)
			this.DetectHiddenWindows(dWin)	; restore prior state
	}

	SetControlDelay(mode:=20,log:=1)
	{
		If (mode != A_ControlDelay) {
			SetControlDelay, % mode
			If log
				RLLog.Trace(A_ThisFunc . " - Delay changed to """ . mode . """ms")
		}
		Return
	}

	SetTitleMatchMode(mode:=2,log:=1)
	{
		If (mode != A_TitleMatchMode) {
			SetTitleMatchMode, % mode
			If log
				RLLog.Trace(A_ThisFunc . " - Mode changed to """ . mode . """")
		}
		Return
	}

	SetWinDelay(mode:=100,log:=1)
	{
		If (mode != A_WinDelay) {
			SetWinDelay, % mode
			If log
				RLLog.Trace(A_ThisFunc . " - Delay changed to """ . mode . """ms")
		}
		Return
	}

	; One-line method to turn the taskbar/start button on/off. Not tested on XP
	; Usage:
	;	MiscUtils.TaskBar("on" or "off")
	TaskBar(mode:="on")
	{
		Global dialogStart
		Static TaskBarTray,StartButton
		If !dialogStart
			dialogStart := this.i18n("dialog.start")

		If !IsObject(TaskBarTray) {
			TaskBarTray := new Window(new WindowTitle("","Shell_TrayWnd"))
			StartButton := new Window(new WindowTitle(dialogStart,"Button"))
		}
		If (mode = "on") {
			TaskBarTray.Show()
			StartButton.Show()
		} Else {
			TaskBarTray.Hide()
			StartButton.Hide()
		}
	}

	; This method kills the taskbar instead of hiding it
	; Idea based off https://autohotkey.com/boards/viewtopic.php?t=905
	TaskBarKill(mode:="on")
	{
		Static TaskBarProcess,TaskBarWindow
		If !StringUtils.Contains(A_OSVersion,"WIN_XP|WIN_VISTA|WIN_7|WIN_8") {	; if OS is not one of these, exit
			RLLog.Warning(A_ThisFunc . " - Cannot kill taskbar as your OS does not support this function: " . A_OSVersion)
			Return
		}

		If !IsObject(TaskBarWindow) {
			TaskBarProcess := new Process(A_WinDir . "\explorer.exe")
			If (A_OSVersion = "WIN_XP") {
				; MsgBox A_OSVersion: %A_OSVersion%`nMode: %mode%`nXP - creating window object
				TaskBarWindow := new Window(new WindowTitle("","Progman"))
			} Else {	; all other OS's
				; MsgBox A_OSVersion: %A_OSVersion%`nMode: %mode%`nNot XP - creating window object
				TaskBarWindow := new Window(new WindowTitle("","Shell_TrayWnd"))
			}
		}
		If (mode = "on") {	; Launch taskbar
			If TaskBarWindow.Exist() {
				; msgbox % A_ThisFunc . " - Taskbar already exists, no need to launch a new one."
				RLLog.Info(A_ThisFunc . " - Taskbar already exists, no need to launch a new one.")
				Return
			} Else {
				If !errLvl := TaskBarProcess.Process("WaitClose",1,"PID") {	; If returned ErrorLevel is 0
					; MsgBox A_OSVersion: %A_OSVersion%`nMode: %mode%`nerrLvl: %errLvl% is 0
					RLLog.Info(A_ThisFunc . " - No explorer process running. Launching explorer.exe to restore the taskbar.")
				} Else {
					RLLog.Warning(A_ThisFunc . " - Taskbar does not exist but explorer.exe is running. Launching explorer.exe again to restore the taskbar.")
					; MsgBox A_OSVersion: %A_OSVersion%`nMode: %mode%`nerrLvl: %errLvl% is not 0
				}
				TaskBarProcess.RunDirect(A_WinDir . "\explorer.exe")
			}
		} Else {	; Kill Taskbar
			If !TaskBarWindow.Exist() {
				; msgbox % A_ThisFunc . " - Taskbar already killed"
				RLLog.Info(A_ThisFunc . " - Taskbar already killed")
				Return
			} Else {
				TaskBarWindow.Get("PID")
				TaskBarProcess.PID := TaskBarWindow.PID	; update process object with the PID of the window object
				If (A_OSVersion = "WIN_XP") {
					; MsgBox A_OSVersion: %A_OSVersion%`nMode: %mode%`nXP
					TaskBarWindow.PostMessage("0x012",0,0)	; WM_QUIT = 0x12
				} Else {
					; MsgBox A_OSVersion: %A_OSVersion%`nMode: %mode%`nNot XP
					TaskBarWindow.PostMessage("0x5B4",0,0)	; WM_USER + 0x1B4	- this method of closing the taskbar causes it to take a long time to restore
				}
			}
		}
	}

	Transform(cmd,value1,value2:="",log:=1)
	{
		Transform,OutputVar, %cmd%, %value1%, %value2%
		If log
			RLLog.Trace(A_ThisFunc . " - From """ . value1 . """ to """ . OutputVar . """")
		Return OutputVar
	}
	
	WinGetActiveStats(ByRef Title,ByRef W,ByRef H,ByRef X,ByRef Y)
	{
		WinGetActiveStats, Title, Width, Height, X, Y
		Return
	}

	WinGetActiveTitle()
	{
		WinGetActiveTitle, OutPutVar
		Return OutPutVar
	}


	; https://support.microsoft.com/en-us/kb/128642
	; This method deals with "Insert Disk in Drive" windows error. This error dialog normally shows up when you have some removable drive showing in Disk Management, like a flash card reader or something, but there is no card plugged in.
	; Mode 0 - This is the default operating mode that serializes the errors and waits for a response.
    ; Mode 1 - If the error does not come from the system, this is the normal operating mode. If the error comes from the system, this logs the error to the event log and returns OK to the hard error. No intervention is required and the popup is not seen.
    ; Mode 2 - This always logs the error to the event log and returns OK to the hard error. Popups are not seen.
	SetErrorMode(errorMode) {
		RLLog.Trace(A_ThisFunc . " - Chaning Error Mode to : " . errorMode)
		Registry.Write("REG_DWORD","HKEY_LOCAL_MACHINE","System\CurrentControlSet\Control\Windows","ErrorMode",errorMode)
	}

}
