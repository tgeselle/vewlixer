MEmu := "Spectaculator"
MEmuV := "v8.0"
MURL := ["http://www.spectaculator.com/"]
MAuthor := ["djvj","brolly","wahoobrian"]
MVersion := "2.0.2"
MCRC := "F3114560"
iCRC := "D4964F8"
MID := "635038268924350920"
MSystem := ["Sinclair ZX Spectrum"]
;----------------------------------------------------------------------------
; Notes:
; Install Spectaculator, on first run put in your registration info and uncheck the box on the Welcome to Spectaculator window.
; On your first exit, uncheck the box to show warning next time and click Yes.
;
; Games are run on 48K model by default, if you want to use a different model for a specific game you can set it on RLUI.
; Configuration example (the key names MUST match your rom name):
;
; [Fish! (Europe)]
; Model=Plus3
; [3D Space Wars (Europe)]
; Model=16K
; [Xybots (Europe)]
; Model=128K
;
; To set your res and ratio, goto Tools->Options->Advanced->Display
; To enable fullscreen, set Fullscreen to true in RLUI
;
; Spectaculator stores its settings in the registry @ HKEY_CURRENT_USER\Software\spectaculator.com\Spectaculator\Settings
; When running compilation games that don't have a selection menu you will be presented with a listing of all games inside the tape where you should 
; select the block you want to load and then close that dialog. Afterwards the module will take care of the loading process.
; These are the games where you need to RW/FW the tape to a specific position in order to play that particular game on the real hardware.
;
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"

Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
defaultModel := IniReadCheck(settingsFile, "Settings", "Model","48K",,1) ; 48K is the default model

If romName contains (16K)
	defaultModel := "16K"
Else If romName contains (128K)
	defaultModel := "128K"
If romName contains (+3)
	defaultModel := "Plus3"

;Read current ini values
currentFullScreen := ReadReg("Settings", "Full Screen")
currentModel := ReadReg("Settings", "Model v6+")
currentCurrah := ReadReg("Plugins\uSpeech", "Enabled")
currentAutoLoad := ReadReg("Plugins\ZX Tape", "AutoLoad")
currentAutoPlay := ReadReg("Plugins\ZX Tape", "AutoPlay")
currentFastLoad := ReadReg("Plugins\ZX Tape", "Fast Load")
currentDetailedTOC := ReadReg("Plugins\ZX Tape", "Detailed TOC")

;Read current registry values
model := IniReadCheck(settingsFile, romName, "Model",defaultModel,,1)
specialrom := IniReadCheck(settingsFile, romName, "SpecialRom","",,1)
currah := IniReadCheck(settingsFile, romName, "Currah","false",,1)
autoLoad := IniReadCheck(settingsFile, romName, "AutoLoad","true",,1)
autoPlay := IniReadCheck(settingsFile, romName, "AutoPlay","true",,1)
fastLoad := IniReadCheck(settingsFile, romName, "FastLoad","true",,1)
detailedTOC := IniReadCheck(settingsFile, romName, "DetailedTOC","false",,1)

;Map model to Registry model codes
If (model = "16K")
	model := "0"
Else If (model = "128K")
	model := "2"
Else If (model = "Plus3")
	model := "5"
Else
	model := "1"

;Clear Special Roms from Registry
WriteRegSZ("Settings", "48k ROM", "") 
WriteRegSZ("Settings", "128k ROM", "")
;Set special rom on registry if needed
If (specialrom)
{
	specialrom := romPath . "\" . specialrom
	CheckFile(specialrom)
	WriteRegSZ("Settings", (If model = "1" ? "48k ROM" : "128k ROM"), specialrom)
}

; Updating registry with desired model number if it is different
If ( currentModel != model )
	WriteReg("Settings", "Model v6+", model)

; Setting Currah MicroSpeech setting in registry if it doesn't match what user wants above
If ( currah != "true" And currentCurrah = 1 )
	WriteReg("Plugins\uSpeech", "Enabled", "0")
Else If ( currah = "true" And currentCurrah = 0 )
	WriteReg("Plugins\uSpeech", "Enabled", "1")

; Setting AutoLoad setting in registry if it doesn't match what user wants above
If ( autoLoad != "true" And currentAutoLoad = 1 )
	WriteReg("Plugins\ZX Tape", "AutoLoad", "0")
Else If ( autoLoad = "true" And currentAutoLoad = 0 )
	WriteReg("Plugins\ZX Tape", "AutoLoad", "1")

; Setting AutoPlay setting in registry if it doesn't match what user wants above
If ( autoPlay != "true" And currentAutoPlay = 1 )
	WriteReg("Plugins\ZX Tape", "AutoPlay", "0")
Else If ( autoPlay = "true" And currentAutoPlay = 0 )
	WriteReg("Plugins\ZX Tape", "AutoPlay", "1")
	
; Setting Fast Load setting in registry if it doesn't match what user wants above
If ( fastLoad != "true" And currentAutoLoad = 1 )
	WriteReg("Plugins\ZX Tape", "Fast Load", "0")
Else If ( fastLoad = "true" And currentAutoLoad = 0 )
	WriteReg("Plugins\ZX Tape", "Fast Load", "1")

; Setting Detailed TOC setting in registry if it doesn't match what user wants above
If ( detailedTOC != "true" And currentDetailedTOC = 1 ) {
	WriteReg("Plugins\ZX Tape", "Detailed TOC", "0")
}	
Else If ( detailedTOC = "true" And currentDetailedTOC = 0 ) {
	WriteReg("Plugins\ZX Tape", "Detailed TOC", "1")
}
If ( detailedTOC = "true")
	WriteReg("Plugins\ZX Tape", "Show Window", "1")
Else 	
	WriteReg("Plugins\ZX Tape", "Show Window", "0")
	
BezelStart()

; Setting Fullscreen setting in registry if it doesn't match what user wants above
If ( Fullscreen != "true" And currentFullScreen = 1 )
	WriteReg("Settings", "Full Screen", 0)
Else If ( Fullscreen = "true" And currentFullScreen = 0 )
	WriteReg("Settings", "Full Screen", 1)

7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class SpectaculatorClass")
WinWaitActive("ahk_class SpectaculatorClass")

; Detect when our emulator is fullscreen and then continue
If Fullscreen = true
	While ( FS_Active != 1 && WinActive(ahk_class SpectaculatorClass) ) {
		CheckFullscreen()
		Sleep, 50
	}

;Dealing with the Detailed TOC window
If (detailedTOC = "true")
{
	WinWait("ahk_class CassetteRecorder") ; waiting for detailedTOC window to open
	Log("Wait for TOC to open - done")
	WinWaitActive("ahk_class CassetteRecorder")
	Log("Wait for TOC to be active - done")
	recorderClosed := "false"
	Loop, 200 {
		If WinVisible("ahk_class CassetteRecorder") {
			Sleep, 100
		}
		Else {
			recorderClosed := "true"
			break
		}
	}
	Log("Wait for TOC to close - done")
	If (recorderClosed = "false")
		 ScriptError("Error waiting for window ahk_class CassetteRecorder to close")

	;Once code reaches here means detailedTOC window has been closed 
	WinActivate, ahk_class SpectaculatorClass
	Log("Activate Spectaculator - done")

	SendCommand("j{LShift Down}{vkDEsc028}{Wait:300}{vkDEsc028}{LShift Up}{Enter}", 500) ;LOAD""
	SendCommand("{Wait:2000}r{Enter}", 1000) ;RUN
}

If bezelEnabled = true
{
	WriteReg("Settings", "StatusBar", 0)
	WriteReg("Settings", "Toolbar", 0)
} Else {
	WriteReg("Settings", "StatusBar", 1)
	WriteReg("Settings", "Toolbar", 1)
}

BezelDraw()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()

WinVisible(Title) {
	currentState := A_DetectHiddenWindows ;Store current value
	DetectHiddenWindows Off ; Force to not detect hidden windows
	funcResult := WinExist(Title) ; Return 0 for hidden windows or the ahk_id
	DetectHiddenWindows %currentState% ; Return to "normal" state
	Return %funcResult%
}

ReadReg(hive, var1) {
	regValue := RegRead("HKEY_CURRENT_USER", "Software\spectaculator.com\Spectaculator\" . hive, var1) 
	;RegRead, regValue, HKEY_CURRENT_USER, Software\spectaculator.com\Spectaculator\%hive%, %var1%
	Return %regValue%
}

WriteReg(hive, var1, var2) {
	RegWrite("REG_DWORD", "HKEY_CURRENT_USER", "Software\spectaculator.com\Spectaculator\" . hive, var1, var2)
	;RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\spectaculator.com\Spectaculator\%hive%, %var1%, %var2%
}

WriteRegSZ(hive, var1, var2) {
	RegWrite("REG_SZ", "HKEY_CURRENT_USER", "Software\spectaculator.com\Spectaculator\" . hive, var1, var2)
}

CheckFullscreen() {
	FS_ABM := DllCall( "RegisterWindowMessage", Str,"AppBarMsg" ), VarSetCapacity( FS_AppBarData,36,0 )
	FS_Off := NumPut(36,FS_AppBarData), FS_Off := NumPut( WinExist(A_ScriptFullPath " - AutoHotkey"), FS_Off+0 )
	FS_Off := NumPut(FS_ABM, FS_Off+0), FS_Off := NumPut( 1,FS_Off+0 ) , FS_Off := NumPut( 1, FS_Off+0 )
	DllCall( "Shell32.dll\SHAppBarMessage", UInt, 0x0, UInt,&FS_APPBARDATA )
	OnMessage( FS_ABM, "FS_Notify" )
}

FS_Notify( wParam, LParam, Msg, HWnd ) {
	Global FS_Active
	FS_Active := LParam
}

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class SpectaculatorClass")
Return
