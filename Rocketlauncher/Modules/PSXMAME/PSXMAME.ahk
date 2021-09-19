MEmu := "PSXMAME"
MEmuV := "v20090903"
MURL := ["http://emulationrealm.net/modules/wfdownloads/singlefile.php?cid=822&lid=1493"]
MAuthor := ["djvj"]
MVersion := "2.0.1"
MCRC := "6384DC63"
MID := "635038268920127414"
MSystem := ["PSXMAME","ZiNc"]
;----------------------------------------------------------------------------
; Notes:
; IMPORTANT *** psxmame.exe is only a frontend for mame.exe. You still need to copy your mame.exe to the psxmame folder or point psxmame to your mame folder for it to work. ***
; Performance is better using zinc.exe for older systems
; If you are using this for a Zinc wheel, make sure your roms and database use standard mame naming, not the numbered ones Zinc requires.
; Uses mame style rom names
; Open the mame.ini and set rompath to your rom dir
; Executable should be pointing to mame.exe, not psxmame.exe (it is not an emulator)
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("MAME","MAME"))	; instantiate primary emulator window object

winstate := "Hide UseErrorLevel"
errLvl := PrimaryExe.Run(romName,winstate)

If errLvl {
	If (errLvl = 1)
		Error := "Failed Validity"
	Else If(errLvl = 2)
		Error := "Missing Files"
	Else If(errLvl = 3)
		Error := "Fatal Error"
	Else If(errLvl = 4)
		Error := "Device Error"
	Else If(errLvl = 5)
		Error := "Game Does Not Exist"
	Else If(errLvl = 6)
		Error := "Invalid Config"
	Else If StringUtils.Contains(errLvl,"7|8|9")
		Error := "Identification Error"
	Else
		Error := "MAME Error"
	RLLog.Error("MAME Error - " . Error)
}

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

FadeInExit()
primaryExe.Process("WaitClose")
FadeOutExit()
ExitModule()


CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
