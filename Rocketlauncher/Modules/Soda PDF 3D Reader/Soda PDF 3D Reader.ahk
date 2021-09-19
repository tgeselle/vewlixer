MEmu := "Soda PDF 3D Reader"
MEmuV := "v7"
MURL := ["http://sodapdf.com/products/free-pdf-reader"]
MAuthor := ["djvj","bleasby"]
MVersion := "1.1"
MCRC := "5122C6F1"
iCRC := "674CD3B4"
MID := "635677589619946938"
MSystem := ["Nintendo Power","Retro Gamer","Magazines","Retro Video Game Magazines"]
;----------------------------------------------------------------------------
; Notes:
; Settings stored in registry @ HKEY_CURRENT_USER\Software\Soda PDF 7
; Bezels do not work with this app
; To set 3D view as default view mode: open Soda and go to Help > Options > Layout > Document View > 3D View 
;----------------------------------------------------------------------------
StartModule()
; BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
nextPage := IniReadCheck(settingsFile, "Settings", "NextPage","",,1)
previousPage := IniReadCheck(settingsFile, "Settings", "PreviousPage","",,1)

; BezelStart()

hideEmuObj := Object("ahk_class UI-ENGINE-SPLASH-WND-CLASS",0,"ahk_class pdf-ui-engine-wnd-class",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable . " """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("ahk_class pdf-ui-engine-wnd-class")
WinWaitActive("ahk_class pdf-ui-engine-wnd-class")

If (fullscreen = "true") {
	Sleep,1250
	Send, {F11 down}{F11 up}
}

; BezelDraw()
HideEmuEnd()
FadeInExit()

If (nextPage) or (previousPage) {
	Sleep, 1000
	If (nextPage)
		xHotKeywrapper(nextPage,"DragPageForward")
	If (previousPage)
		xHotKeywrapper(previousPage,"DragPageBackward")
}

Process("WaitClose", executable)
7zCleanUp()
; BezelExit()
FadeOutExit()
ExitModule()


DragPageForward:
	WinActivate, ahk_class pdf-ui-engine-wnd-class
	MouseClickDrag, L, % (2*A_ScreenWidth)//3, % (A_ScreenHeight)//5, % (A_ScreenWidth)//3, % (A_ScreenHeight)//5
Return
DragPageBackward:
	WinActivate, ahk_class pdf-ui-engine-wnd-class
	MouseClickDrag, L, % (A_ScreenWidth)//3, % (A_ScreenHeight)//5, % (2*A_ScreenWidth)//3, % (A_ScreenHeight)//5
Return

CloseProcess:
	FadeOutStart()
	WinClose("ahk_class pdf-ui-engine-wnd-class")
Return
