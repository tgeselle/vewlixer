MEmu := "SumatraPDF"
MEmuV := "v3.0"
MURL := ["http://www.sumatrapdfreader.org"]
MAuthor := ["zerojay"]
MVersion := "1.0"
MCRC := "948F796A"
iCRC := "80A2764B"
MID := "635668938114496562"
MSystem := ["Nintendo Power","Retro Gamer","Magazines","Retro Video Game Magazines"]
;----------------------------------------------------------------------------
; Notes:
; You can set ESC to exit through the Advanced Options in SumatraPDF, which will open a text file to make the change.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","presentation",,1)
ViewMode := IniReadCheck(settingsFile, "Settings", "ViewMode","book view",,1)

BezelStart()
Fullscreen := If Fullscreen = "true" ? " -fullscreen" : ""

hideEmuObj := Object("SumatraPDF ahk_class SUMATRA_PDF_FRAME",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

HideEmuStart()
Run(executable . Fullscreen . " -view" . " """ . ViewMode . """" . " """ . romPath . "\" . romName . romExtension . """", emuPath)

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("SumatraPDF ahk_class SUMATRA_PDF_FRAME")
Return
