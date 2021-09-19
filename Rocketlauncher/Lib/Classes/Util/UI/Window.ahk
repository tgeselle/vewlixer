MCRC := "F6AFB0D3"
MVersion := "1.2.5"

; Instantiated by creating the window instance first:
; window := new Window(new WindowTitle(""Title"",""Class"",""Exe"",""ID"",""PID""))
; errLvl := window.Activate()
class Window
{
	;vars
	; Controls
	; Hidden		; If 1, denotes window was hidden with Hide()
	; WinText
	; ExcludeTitle
	; ExcludeText

	; With WindowTitle, these are available:
	; WinTitle.Title
	; WinTitle.Class
	; WinTitle.Exe
	; WinTitle.ID
	; WinTitle.PID

	; If GetPos() is called, these can be available:
	; X	; current X position
	; Y	; current Y position
	; W	; current Width
	; H	; current Height

	; If Get() is called, these can be available for each cmd requested:
	; ID
	; IDLast
	; PID
	; ProcessName
	; ProcessPath
	; Count
	; List
	;   List[0]		; amount of windows found
	;   List[1]		; unique ID of 1st window
	;   List[2]		; unique ID of 2nd window
	;   List[etc]
	; MinMax
	; ControlList
	; ControlListHwnd
	; Transparent
	; TransColor
	; Style
	; ExStyle
	
	__New(WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:="")
	{
		this.WinTitle := WinTitle
		; msgbox % "Window: " . this.WinTitle.Title
		this.WinText := WinText
		this.ExcludeTitle := ExcludeTitle
		this.ExcludeText := ExcludeText
		If !(this.WinTitle.Title || this.WinTitle.Class || this.WinTitle.Exe || this.WinTitle.ID || this.WinTitle.PID)
			ScriptError(A_ThisFunc . ": Improper construction of Window object. Use this syntax: var := new Window(new WindowTitle(""Title"",""Class"",""Exe"",""ID"",""PID""))")
		Else
			RLLog.Trace(A_ThisFunc . " - Created: """ . this.WinTitle.GetWindowTitle() . """")
		; msgbox % "Window: " . this.GetWindowTitle()
	}

	__Delete()
	{
		this.Controls := ""
		this.Hidden := ""
		this.WinTitle := ""
		this.WinText := ""
		this.ExcludeTitle := ""
		this.ExcludeText := ""
	}

	; Properties (only supported in AHK v1.1.16+
	; WindowTitle[]
	; {
		; Get {
			; Return this.WinTitle.GetWindowTitle()
		; }
	; }

	; Functions
	Active(log:=1)
	{
		errLvl := WinActive(this.WinTitle.GetWindowTitle(),this.WinText,this.ExcludeTitle,this.ExcludeText)
		If log
			RLLog.Trace(A_ThisFunc . " - """ . this.WinTitle.GetWindowTitle() . """ is " . (If errLvl ? "" : "not ") . "the active window")
		Return errLvl
	}

	Activate(log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Activating window """ . this.WinTitle.GetWindowTitle() . """")
		WinActivate, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		Return ErrorLevel
	}

	; Centers this window on primary desktop
	Center() {
		this.GetPos(X,Y,W,H)
		X := (A_ScreenWidth / 2) - (W / 2)
		Y := (A_ScreenHeight / 2) - (H / 2)
		this.Move(X,Y)
	}

	; titleMode = Useful when you want to change how AHK matches titles. See here for more info http://hotkeyit.github.io/v2/docs/commands/SetTitleMatchMode.htm
	Close(secondsToWait:="",titleMode:="")
	{
		If titleMode {
			curTitleMode := A_TitleMatchMode 
			MiscUtils.SetTitleMatchMode(titleMode)
		}
		RLLog.Trace(A_ThisFunc . " - Closing: """ . this.WinTitle.GetWindowTitle() . """")
		WinClose, % this.WinTitle.GetWindowTitle(), % this.WinText , % secondsToWait, % this.ExcludeTitle, % this.ExcludeText
		; MsgBox % A_ThisFunc . "`n" . this.WinTitle.GetWindowTitle()
		If (secondsToWait = "" || !secondsToWait)
			secondsToWait := 2	; need to always have some timeout for this command otherwise it will wait forever
		WinWaitClose, % this.WinTitle.GetWindowTitle(), % this.winText , % secondsToWait, % this.ExcludeTitle, % this.ExcludeText	; only WinWaitClose reports an ErrorLevel
		If titleMode
			MiscUtils.SetTitleMatchMode(curTitleMode)
		Return ErrorLevel
	}

	; Create control object for use in this window object
	; Usage:
	; WindowObject.CreateControl("Control_Name")
	CreateControl(ControlName,log:=1) {
		this.Controls[ControlName] := new Control(ControlName, this)
		If log
			RLLog.Trace(A_ThisFunc . " - Created new control for """ . ControlName . """")
	}

	Exist(log:=1)
	{
		ID := WinExist(this.WinTitle.GetWindowTitle(), this.WinText, this.ExcludeTitle, this.ExcludeText)
		If log
			RLLog.Trace(A_ThisFunc . " - " . (ID ? "Retrieved the HWND ID """ . ID . """" : "Window does not exist"))
		Return ID
	}

	Get(cmd,log:=1)
	{
		WinGet,OutputVar, % cmd, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		If (cmd = "List") {		; add each window's hwnd to the object
			this.List[0] := OutputVar	; store amount of windows found
			Loop % OutputVar {
				this.List[A_Index] := OutputVar%A_Index%
			}
		} Else
			this[cmd] := OutputVar	; add this element to the object
		If log
			RLLog.Trace(A_ThisFunc . " - " . cmd . " is """ . OutputVar . """ from """ . this.WinTitle.GetWindowTitle() . """")
		Return
	}

	GetClass(StoreClass:=1,log:=1)
	{
		WinGetClass,OutputVar, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		If StoreClass
			this.WinTitle.Class := OutputVar	; set the returned class as this object's ahk_class
		If log
			RLLog.Trace(A_ThisFunc . " - Retrieved """ . OutputVar . """ from """ . this.WinTitle.GetWindowTitle() . """")
		Return OutputVar
	}

	GetControl(ControlName) {
		Return this.Controls[ControlName]
	}

	GetTitle(StoreTitle:=1,log:=1)
	{
		WinGetTitle,OutputVar, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		If StoreTitle
			this.WinTitle.Title := OutputVar	; set the returned title as this object's ahk_class
		If log
			RLLog.Trace(A_ThisFunc . " - Retrieved """ . OutputVar . """ from """ . this.WinTitle.GetWindowTitle() . """")
		Return OutputVar
	}

	GetPos(ByRef x:="",ByRef y:="",ByRef w:="",ByRef h:="",log:=1)
	{
		dWin := A_DetectHiddenWindows	; store current value to return later
		If (dWin != "Off")
			MiscUtils.DetectHiddenWindows("Off")	; If DetectHiddenWindows is on, this can cause random hidden windows to be associated to an application to be chosen, causing irratic results.
		WinGetPos,x,y,w,h, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		; MsgBox % A_ThisFunc . "`n" . A_Index . "`n" . this.WinTitle.GetWindowTitle() . "`nx:" . x . " y:" . y . " w: " . w . " h: " . h
		this.X := x
		this.Y := y
		this.W := W
		this.H := H
		If log
			RLLog.Trace(A_ThisFunc . " - Retrieved x:" . x . " y:" . y . " w: " . w . " h: " . h . " from """ . this.WinTitle.GetWindowTitle() . """")
		If (dWin != A_DetectHiddenWindows)
			MiscUtils.DetectHiddenWindows(dWin)	; If DetectHiddenWindows is on, this can cause random hidden windows to be associated to an application to be chosen, causing irratic results.
		Return
	}

	Hide()
	{
		RLLog.Trace(A_ThisFunc . " - Hiding window """ . this.WinTitle.GetWindowTitle() . """")
		WinHide, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		this.Hidden := 1
		Return ErrorLevel
	}

	Maximize(keepAspectRatio:="true", removeTitle:="true", removeBorder:="true", removeToggleMenu:="true")
	{
		RLLog.Debug(A_ThisFunc . " - Started to process window """ . this.WinTitle.GetWindowTitle() . """")
		If (removeTitle = "true")
			this.RemoveTitlebar()	; Removes the titlebar of the game window
		If (removeBorder = "true")
			this.RemoveBorder()	; Removes the border of the game window
		If (removeToggleMenu = "true") {
			this.Get("ID")
			this.RemoveMenubar()
		}

		If (keepAspectRatio = "true") {
			this.GetPos(appX,appY,appWidth,appHeight)
			widthMaxPercenty := (A_ScreenWidth / appWidth)
			heightMaxPercenty := (A_ScreenHeight / appHeight)

			If  (widthMaxPercenty < heightMaxPercenty)
				percentToEnlarge := widthMaxPercenty
			Else
				percentToEnlarge := heightMaxPercenty

			appWidthNew := appWidth * percentToEnlarge
			appHeightNew := appHeight * percentToEnlarge

			currentFloat := A_FormatFloat 
			SetFormat,Float,0.0	; set float to whole numbers only
			appY := MiscUtils.Transform("Round", appY)
			appWidthNew := MiscUtils.Transform("Round", appWidthNew, 2)
			appHeightNew := MiscUtils.Transform("Round", appHeightNew, 2)
			appXPos := (A_ScreenWidth / 2) - (appWidthNew / 2)
			appYPos := (A_ScreenHeight / 2) - (appHeightNew / 2)
			SetFormat,Float,%currentFloat%	; return format to previous state
		} Else {
			appXPos := 0
			appYPos := 0
			appWidthNew := A_ScreenWidth
			appHeightNew := A_ScreenHeight
		}
		this.Move(appXPos,appYPos,appWidthNew,appHeightNew,2000)
		RLLog.Debug(A_ThisFunc . " - Ended")
	}

	; titleMode = Useful when you want to change how AHK matches titles. See here for more info http://hotkeyit.github.io/v2/docs/commands/SetTitleMatchMode.htm
	MenuSelectItem(Menu:="",SubMenu1:="",SubMenu2:="",SubMenu3:="",SubMenu4:="",SubMenu5:="",SubMenu6:="",titleMode:="")
	{
		If titleMode {
			curTitleMode := A_TitleMatchMode 
			MiscUtils.SetTitleMatchMode(titleMode)
		}
		If (!Menu || !SubMenu1)
			ScriptError("Menu and SubMenu are required for WindowUtils.WinMenuSelectItem")
		RLLog.Debug(A_ThisFunc . " - Selecting " . Menu . " -> " . SubMenu1 . (SubMenu2 ? " -> " . SubMenu2 : "") . (SubMenu3 ? " -> " . SubMenu3 : "") . (SubMenu4 ? " -> " . SubMenu4 : "") . (SubMenu5 ? " -> " . SubMenu5 : "") . (SubMenu6 ? " -> " . SubMenu6 : ""))
		WinMenuSelectItem, % this.WinTitle.GetWindowTitle(), % this.WinText, %Menu%, %SubMenu1%, %SubMenu2%, %SubMenu3%, %SubMenu4%, %SubMenu5%, %SubMenu6%, % this.ExcludeTitle, % this.ExcludeText
		If titleMode
			MiscUtils.SetTitleMatchMode(curTitleMode)
		Return ErrorLevel
	}

	Minimize()
	{
		RLLog.Trace(A_ThisFunc . " - Minimizing " . this.WinTitle.GetWindowTitle())
		WinMinimize, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		Return
	}

	; When timeLimit is set, assures that a window is moved to the desired position within a timeout
	Move(X,Y,W:="",H:="",timeLimit:="",ignoreWin:="",log:=1)
	{
		WinMove, % this.WinTitle.GetWindowTitle(), % this.WinText, % x, % y, % w, % h, % this.ExcludeTitle, % this.ExcludeText
		;check If window moved
		timeout := A_TickCount
		If timeLimit {
			RLLog.Debug(A_ThisFunc . " - Moving window within " . timeLimit . "ms: " . this.WinTitle.GetWindowTitle() . " to X=" . X . ", Y=" . Y . ", W=" . W . " H=" . H)
			Loop {
				Xgot:="",Ygot:="",Wgot:="",Hgot:=""
				this.GetPos(Xgot,Ygot,Wgot,Hgot,0) ;,"")	; do not log
				; MsgBox % A_ThisFunc . "`n" . A_Index . "`n" . this.WinTitle.GetWindowTitle() . "`nxgot:" . Xgot . " ygot:" . Ygot . " wgot: " . Wgot . " hgot: " . Hgot . "`nx:" . X . " y:" . Y . " w: " . W . " h: " . H
				If ((Xgot=X) and (Ygot=Y) and (Wgot=W) and (Hgot=H)) {
					success++
					If success >= 5
					{
						RLLog.Debug(A_ThisFunc . " - Successful: Window " . this.WinTitle.GetWindowTitle() . " moved to X=" . X . ", Y=" . Y . ", W=" . W . " H=" . H)
						error := 0
						Break
					}
					; Sleep, 1000
					Continue
				}
				If (timeout<A_TickCount-timeLimit){
					RLLog.Warning(A_ThisFunc . " - Failed: Window " . this.WinTitle.GetWindowTitle() . " at X=" . Xgot . ", Y=" . Ygot . ", W=" . Wgot . " H=" . Hgot)
					error := 1
					Break
				}
				Sleep, 200
				WinMove, % this.WinTitle.GetWindowTitle(), % this.WinText, % x, % y, % w, % h, % this.ExcludeTitle, % this.ExcludeText
			}
			Return error
		} Else
			If log
				RLLog.Debug(A_ThisFunc . " - Moved " . this.WinTitle.GetWindowTitle() . " to  x:" . x . " y:" . y . " w: " . w . " h: " . h)
		Return
	}

	; Purpose: Handle an emulators Open Rom window when CLI is not an option
	; Returns 1 when successful
	OpenROM(selectedRomName) {
		Global MEmu,moduleName
		RLLog.Debug(A_ThisFunc . " - Started")
		this.Wait()
		this.WaitActive()
		state := 0
		Loop, 150	; ~15 seconds
		{
			this.CreateControl("Edit1")		; instantiate new control for Edit1
			this.GetControl("Edit1").SetText(selectedRomName)	; set Edit1 text to romName
			edit1Text := this.GetControl("Edit1").GetText()
			If (edit1Text = selectedRomName) {
				state := 1
				RLLog.Debug(A_ThisFunc . " - Successfully set romName into """ . this.WinTitle.GetWindowTitle() . """ in " . A_Index . " " . (If A_Index = 1 ? "try." : "tries."))
				Break
			}
			TimerUtils.Sleep(100,0)
		}
		If (state != 1)
			ScriptError("Tried for 15 seconds to send the romName to " . MEmu . " but was unsuccessful. Please try again with Fade and Bezel disabled and put the " . moduleName . " in windowed mode to see if the problem persists.", 10)
		this.PostMessage("0x111", 1)	; Select Open
		RLLog.Debug(A_ThisFunc . " - Ended")
		Return state
	}

	PostMessage(Msg,wParam:=0,lParam:=0,vControl:="",log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Posting " . Msg . " to " . this.WinTitle.GetWindowTitle())
		PostMessage, % Msg, % wParam, % lParam, % vControl, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		Return ErrorLevel
	}

	SendMessage(Msg,wParam:=0,lParam:=0,vControl:="",Timeout:=5000,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Sending " . Msg . " to " . this.WinTitle.GetWindowTitle())
		SendMessage, % Msg, % wParam, % lParam, % vControl, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText, % Timeout
		Return ErrorLevel
	}

	RemoveBorder()
	{
		RLLog.Trace(A_ThisFunc . " - Removing border for """ . this.WinTitle.GetWindowTitle() . """")
		Loop {	; windows often don't take the first few times, so trying multiple times to remove the border
			errLvl := this.Set("Style", "-0xC40000")	; Removes the border of the game window
			this.Get("Style")
			If (this.Style & 0xC40000) {
				RLLog.Trace(A_ThisFunc . " - Could not remove border yet")
				; ToolTip % this.Style
			} Else {
				RLLog.Trace(A_ThisFunc . " - Removed border")
				Break
			}
			Sleep, 50
		}
		Return errLvl
	}

	RemoveTitleBar()
	{
		RLLog.Trace(A_ThisFunc . " - Removing titlebar for """ . this.WinTitle.GetWindowTitle() . """")
		Loop {	; windows often don't take the first few times, so trying multiple times to remove the titlebar
			errLvl := this.Set("Style", "-0xC00000")	; Removes the titlebar of the game window
			this.Get("Style")
			If (this.Style & 0xC00000) {
				RLLog.Trace(A_ThisFunc . " - Could not remove titlebar yet")
				; ToolTip % this.Style
			} Else {
				RLLog.Trace(A_ThisFunc . " - Removed titlebar")
				Break
			}
			Sleep, 50
		}
		Return errLvl
	}

	RemoveMenubar()
	{
		If !this.ID {
			this.Get("ID")	; retrieve ID of this window
			If !this.ID
				RLLog.Warning(A_ThisFunc . " - Could not retrieve this window's ID: " . this.WinTitle.GetWindowTitle())
		}
		If !this.hMenu
			this.hMenu := DllCall("GetMenu", "uint", this.ID)	; store the menubar ID so it can be restored later
		hMenuCur := DllCall("GetMenu", "uint", this.ID)
		timeout := A_TickCount
		If hMenuCur {	; menubar is currently visible
			Loop {
				;ToolTip, menubar is visible`, hiding it`nhMenuCur: %hMenuCur%`n%A_Index%
				hMenuCur := DllCall("GetMenu", "uint", this.ID)
				If !hMenuCur {
					RLLog.Debug(A_ThisFunc . " - MenuBar is now hidden for " . this.ID)
					Break	; menubar is now hidden, break out
				}
				DllCall("SetMenu", "uint", this.ID, "uint", 0)
				If (timeout < A_TickCount - 1000) {	; prevents an infinite loop and breaks after 2 seconds
					RLLog.Warning(A_ThisFunc . " - Timed out trying to hide MenuBar for " . this.ID)
					Break
				}
			}
		} Else
			RLLog.Trace(A_ThisFunc . " - MenuBar is already hidden or does not exist for: " . this.WinTitle.GetWindowTitle())
	}

	Restore()
	{
		RLLog.Trace(A_ThisFunc . " - Restoring window """ . this.WinTitle.GetWindowTitle() . """")
		WinRestore, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		Return ErrorLevel
	}

	Set(Attribute,Value)
	{
		RLLog.Trace(A_ThisFunc . " - Setting " . Attribute . " to " . Value . " for window """ . this.WinTitle.GetWindowTitle() . """")
		WinSet, %Attribute%, %Value%, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		Return ErrorLevel
	}

	Show()
	{
		RLLog.Trace(A_ThisFunc . " - Unhiding window """ . this.WinTitle.GetWindowTitle() . """")
		WinShow, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		this.Hidden := ""
		Return ErrorLevel
	}

	; Toggles hiding/showing a MenuBar
	; Usage: Provide the window's PID of the window you want to toggle the MenuBar
	; used in BGB & nulldc module and bezel
	; Requires the ID of the window to exist in the object first
	ToggleMenu()
	{
		If !this.ID {
			this.Get("ID")	; retrieve ID of this window
			If !this.ID
				RLLog.Warning(A_ThisFunc . " - Could not retrieve this window's ID: " . this.WinTitle.GetWindowTitle())
		}
		If !this.hMenu
			this.hMenu := DllCall("GetMenu", "uint", this.ID)	; store the menubar ID so it can be restored later
		hMenuCur := DllCall("GetMenu", "uint", this.ID)
		timeout := A_TickCount
		If !hMenuCur {	; menubar is currently hidden
			Loop {
				;ToolTip, menubar is hidden`, bringing it back`nhMenuCur: %hMenuCur%`n%A_Index%
				hMenuCur := DllCall("GetMenu", "uint", this.ID)
				If hMenuCur {
					RLLog.Debug(A_ThisFunc . " - MenuBar is now visible for " . this.ID)
					Break	; menubar is now visible, break out
				}
				DllCall("SetMenu", "uint", this.ID, "uint", this.hMenu)
				If (timeout < A_TickCount - 1000) {	; prevents an infinite loop and breaks after 2 seconds
					RLLog.Warning(A_ThisFunc . " - Timed out trying to restore MenuBar for " . this.ID)
					Break
				}
			}
		} Else {	; menubar is currently visible
			Loop {
				;ToolTip, menubar is visible`, hiding it`nhMenuCur: %hMenuCur%`n%A_Index%
				hMenuCur := DllCall("GetMenu", "uint", this.ID)
				If !hMenuCur {
					RLLog.Debug(A_ThisFunc . " - MenuBar is now hidden for " . this.ID)
					Break	; menubar is now hidden, break out
				}
				DllCall("SetMenu", "uint", this.ID, "uint", 0)
				If (timeout < A_TickCount - 1000) {	; prevents an infinite loop and breaks after 2 seconds
					RLLog.Warning(A_ThisFunc . " - Timed out trying to hide MenuBar for " . this.ID)
					Break
				}
			}
		}
	}

	; waitMode = Only wait for this element of the title, not the entire title returned from GetWindowTitle()
	; titleMode = Useful when you want to change how AHK matches titles. See here for more info http://hotkeyit.github.io/v2/docs/commands/SetTitleMatchMode.htm
	; silenceError = Use this when you want to wait a brief moment for a window but not error because it never showed
	Wait(secondsToWait:="",waitMode:="",titleMode:="",silenceError:="")
	{
		Global detectFadeErrorEnabled,logLevel
		If titleMode {
			curTitleMode := A_TitleMatchMode 
			MiscUtils.SetTitleMatchMode(titleMode)
		}
		If (waitMode != "")
			If !StringUtils.Contains(waitMode,"Class|Exe|ID|PID",0)
				ScriptError(A_ThisFunc . " - Invalid waitmode supplied: " . waitMode . ". Valid waitmodes are Class|Exe|ID|PID.")
		If logLevel > 3
			MiscUtils.GetActiveWindowStatus()	; only used for logging active window info
		RLLog.Info(A_ThisFunc . " - Waiting for window """ . (If waitMode ? "ahk_" . waitMode : this.WinTitle.GetWindowTitle()) . """")
		WinWait, % (If waitMode ? "ahk_" . waitMode : this.WinTitle.GetWindowTitle()), % this.WinText, % (secondsToWait ? secondsToWait : 30), % this.ExcludeTitle, % this.ExcludeText
		errLvl := ErrorLevel	; have to store this because GetActiveWindowStatus will reset it
		If logLevel > 3
			MiscUtils.GetActiveWindowStatus()	; only used for logging active window info
		If (silenceError = "") {	; do not log or show an error when silence error is used. 
			If (errLvl && detectFadeErrorEnabled = "true")
				ScriptError("There was an error waiting for the window """ . this.WinTitle.GetWindowTitle() . """. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",10)
			Else If (errLvl && detectFadeErrorEnabled != "true")
				RLLog.Error(A_ThisFunc . " - There was an error waiting for the window """ . this.WinTitle.GetWindowTitle() . """. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.")
		}
		If titleMode
			MiscUtils.SetTitleMatchMode(curTitleMode)
		Return errLvl
	}

	; waitMode = Only wait for this element of the title, not the entire title returned from GetWindowTitle()
	; titleMode = Useful when you want to change how AHK matches titles. See here for more info http://hotkeyit.github.io/v2/docs/commands/SetTitleMatchMode.htm
	; silenceError = Use this when you want to wait a brief moment for a window but not error because it never showed
	WaitActive(secondsToWait:="",waitMode:="",titleMode:="",silenceError:="")
	{
		Global detectFadeErrorEnabled,logLevel,emulatorProcessID,emulatorVolumeObject,emulatorInitialMuteState,fadeMuteEmulator,fadeIn
		If titleMode {
			curTitleMode := A_TitleMatchMode 
			MiscUtils.SetTitleMatchMode(titleMode)
		}
		If (waitMode != "")
			If !StringUtils.Contains(waitMode,"Class|Exe|ID|PID",0)
				ScriptError(A_ThisFunc . " - Invalid waitmode supplied: " . waitMode . ". Valid waitmodes are Class|Exe|ID|PID.")
		If (logLevel > 3)
			MiscUtils.GetActiveWindowStatus()	; only used for logging active window info
		RLLog.Info(A_ThisFunc . " - Waiting for """ . (If waitMode ? "ahk_" . waitMode : this.WinTitle.GetWindowTitle()) . """")
		WinWaitActive, % (If waitMode ? "ahk_" . waitMode : this.WinTitle.GetWindowTitle()), % this.WinText, % (secondsToWait ? secondsToWait : 30), % this.ExcludeTitle, % this.ExcludeText
		errLvl := ErrorLevel	; have to store this because GetActiveWindowStatus will reset it
		If (logLevel > 3)
			MiscUtils.GetActiveWindowStatus()	; only used for logging active window info
		If (silenceError = "") {	; do not log or show an error when silence error is used. 
			If (errLvl and detectFadeErrorEnabled = "true")
				ScriptError("There was an error waiting for the window """ . this.WinTitle.GetWindowTitle() . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.",10)
			Else If (errLvl and detectFadeErrorEnabled != "true")
				RLLog.Error(A_ThisFunc . " - There was an error waiting for the window """ . this.WinTitle.GetWindowTitle() . """ to become active. Please check you have the correct version emulator installed for this module, followed any notes in the module, and have this emulator working outside your Frontend first. Also turn off Fade to see if you are hiding your problem.")
		}
		If !errLvl {
			WinGet emulatorProcessID, PID, % this.WinTitle.GetWindowTitle()
			emulatorVolumeObject := GetVolumeObject(emulatorProcessID)
			If ((fadeMuteEmulator = "true") and (fadeIn = "true")){
				getMute(emulatorInitialMuteState, emulatorVolumeObject)
				setMute(1, emulatorVolumeObject)
			}
		}
		If titleMode
			MiscUtils.SetTitleMatchMode(curTitleMode)
		Return errLvl
	}

	; titleMode = Useful when you want to change how AHK matches titles. See here for more info http://hotkeyit.github.io/v2/docs/commands/SetTitleMatchMode.htm
	WaitClose(secondsToWait:="",titleMode:="")
	{
		If titleMode {
			curTitleMode := A_TitleMatchMode 
			MiscUtils.SetTitleMatchMode(titleMode)
		}
		RLLog.Info(A_ThisFunc . " - Waiting for """ . this.WinTitle.GetWindowTitle() . """ to close")
		WinWaitClose, % this.WinTitle.GetWindowTitle(), % this.WinText, %secondsToWait%, % this.ExcludeTitle, % this.ExcludeText
		If titleMode
			MiscUtils.SetTitleMatchMode(curTitleMode)
		Return ErrorLevel
	}
	
	ControlSend(Keys,Control:="ahk_parent",log:=1)
	{
		ControlSend, % Control, % Keys, % this.WinTitle.GetWindowTitle(), % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		errLvl := ErrorLevel
		If log
			RLLog.Trace(A_ThisFunc . " - Sent """ . Keys . """ to control """ . Control . """ on """ . this.WinTitle.GetWindowTitle() . """")
		Return errLvl
	}
}
