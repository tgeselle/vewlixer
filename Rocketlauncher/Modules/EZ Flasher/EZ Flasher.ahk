MEmu := "EZ Flasher"
MEmuV := "v1.0"
MURL := ["http://www.hyperspin-fe.com/topic/768-ez-flasher-simple-flash-loader/?hl=flasher"]
MAuthor := ["djvj"]
MVersion := "2.0.1"
MCRC := "410F4576"
iCRC := ""
MID := "635038268889251707"
MSystem := ["Flash Games"]
;----------------------------------------------------------------------------
; Notes:
;----------------------------------------------------------------------------
StartModule()
FadeInStart()
7z(romPath, romName, romExtension, 7zExtractPath)

Run(executable . " -""" . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("E-Z Flasher ahk_class WindowsForms10.Window.8.app.0.33c0d9d")
WinWaitActive("E-Z Flasher ahk_class WindowsForms10.Window.8.app.0.33c0d9d")

FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	WinClose("E-Z Flasher ahk_class WindowsForms10.Window.8.app.0.33c0d9d")
Return
