MCRC := "78B1DCAE"
MVersion := "1.2.2"

; Instantiated by creating the control instance first:
; control := new Control(control,WinTitle="",WinText="",ExcludeTitle="",ExcludeText="")
; OutPutVar := control.GetText()
class Control
{
	;vars
	; ControlName
	; MainWindow 	; This is an instance of the Window class

	; If Get() is called, these can be available for each cmd requested:
	; Checked
	; Enabled
	; Visible
	; Tab
	; FindString
	; Choice
	; List
	; LineCount
	; CurrentLine
	; CurrentCol
	; Line
	; Selected
	; Style
	; ExStyle
	; Hwnd

	__New(ControlName, MainWindow)
	{
		this.ControlName := If ControlName = "TopMost" ? "" : ControlName	; name of the control to manipulate. TopMost does not use a control name but sends command to the topmost control of the window
		this.MainWindow := MainWindow	; the window object this control belongs to
	}

	__Delete()
	{
		this.ControlName := ""
		this.MainWindow := ""
	}

	Click(ConPos:="",WhichButton:="LEFT",ClickCount:=1,Options:="",log:=1)
	{
		If (ConPos = "null")
			controlVar := ""	; clicks top most Control
		Else If (ConPos = "")
			controlVar := this.ControlName	; clicks the control name of this object
		Else
			controlVar := ConPos	; clicks the position supplied in the 1st paramater. Useful for specifying an X,Y coordinate relative to the target window's upper left corner (ex: "X55 Y33")
		ControlClick, % controlVar, % this.MainWindow.WinTitle.GetWindowTitle(), % this.MainWindow.WinText, % WhichButton, % ClickCount, % Options, % this.MainWindow.ExcludeTitle, % this.MainWindow.ExcludeText
		If log
			RLLog.Trace(A_ThisFunc . " - Clicked control """ . controlVar . """ on window """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
	}

	Control(cmd,Value:="",log:=1)
	{
		Control, % cmd, % Value, % this.ControlName, % this.MainWindow.WinTitle.GetWindowTitle(), % this.MainWindow.WinText, % this.MainWindow.ExcludeTitle, % this.MainWindow.ExcludeText
		errLvl := ErrorLevel
		If log
			RLLog.Trace(A_ThisFunc . " - Set """ . cmd . """ to control """ . this.ControlName . """ on """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
		Return errLvl
	}

	Get(cmd,Value:="",log:=1)
	{
		ControlGet,OutputVar, % cmd, % Value, % this.ControlName, % this.MainWindow.WinTitle.GetWindowTitle(), % this.MainWindow.WinText, % this.MainWindow.ExcludeTitle, % this.MainWindow.ExcludeText
		errLvl := ErrorLevel
		this[cmd] := OutputVar	; add this element to the object
		If log
			RLLog.Trace(A_ThisFunc . " - Retrieved """ . OutputVar . """ from """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
		Return errLvl
	}

	GetPos(ByRef x:="",ByRef y:="",ByRef w:="",ByRef h:="",log:=1)
	{
		ControlGetPos, x, y, w, h, % this.ControlName, % this.MainWindow.WinTitle.GetWindowTitle(), % this.MainWindow.WinText, % this.MainWindow.ExcludeTitle, % this.MainWindow.ExcludeText
		If log
			If (!x && !y && !w && !h)
				RLLog.Trace(A_ThisFunc . " - Could not find control """ . this.ControlName . """ in window """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
			Else
				RLLog.Trace(A_ThisFunc . " - """ . this.ControlName . """ returned position ""x:" . x . """ y:" . y . """ w:" . w . """ h:" . h . """ from """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
		Return
	}

	GetText(log:=1)
	{
		ControlGetText, OutPutVar , % this.ControlName, % this.MainWindow.WinTitle.GetWindowTitle(), % this.MainWindow.WinText, % this.MainWindow.ExcludeTitle, % this.MainWindow.ExcludeText
		If log
			RLLog.Trace(A_ThisFunc . " - Retrieved text """ . OutPutVar . """ from """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
		If ErrorLevel
			RLLog.Trace(A_ThisFunc . " - There was an error retrieving the text")
		Return OutPutVar
	}

	Send(Keys,log:=1)
	{
		ControlSend, % this.ControlName, % Keys, % this.MainWindow.WinTitle.GetWindowTitle(), % this.MainWindow.WinText, % this.MainWindow.ExcludeTitle, % this.MainWindow.ExcludeText
		errLvl := ErrorLevel
		If log
			RLLog.Trace(A_ThisFunc . " - Sent """ . Keys . """ to control """ . this.ControlName . """ on """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
		Return errLvl
	}

	SetText(NewText:="",log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Setting control """ . this.ControlName . " on """ . this.MainWindow.WinTitle.GetWindowTitle() . """")
		ControlSetText, % this.ControlName, %NewText%, % this.MainWindow.WinTitle.GetWindowTitle(), % this.MainWindow.WinText, % this.MainWindow.ExcludeTitle, % this.MainWindow.ExcludeText
		Return ErrorLevel
	}
}
