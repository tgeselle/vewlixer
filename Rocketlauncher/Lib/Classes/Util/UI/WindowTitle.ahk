MCRC := "24DC8E15"
MVersion := "1.0.1"

; Constructor class that constructs the WinTitle for use in the Window class
; Instantiated by creating the WindowTitle instance first. Used with Window class like so:
; Window := new Window(new WindowTitle("TITLE","CLASS","ProcessName","ID","PID"))
class WindowTitle
{
	;vars
	; Title	; The window title text
	; Class	; the ahk_Class of the window. Class name
	; Exe	; the ahk_EXE of the window. Process name/path
	; ID	; the ahk_ID of the window. Unique ID/HWND
	; PID	; the ahk_PID of the window. Process ID

	__New(Title:="",Class:="",Exe:="",ID:="",PID:="")
	{
		; msgbox % "WindowTitle: " . Class
		this.Title := Title
		this.Class := Class
		this.Exe := Exe
		this.ID := ID
		this.PID := PID
	}

	__Delete()
	{
		this.Title := ""
		this.Class := ""
		this.Exe := ""
		this.ID := ""
		this.PID := ""
	}

    GetWindowTitle()
    {
		Return Trim((this.Title ? this.Title : "")
			  . (this.Class ? " ahk_class " . this.Class : "")
			  . (this.Exe ? " ahk_exe " . this.Exe : "")
			  . (this.ID ? " ahk_id " . this.ID : "")
			  . (this.PID ? " ahk_pid " . this.PID : ""))
   }
}
