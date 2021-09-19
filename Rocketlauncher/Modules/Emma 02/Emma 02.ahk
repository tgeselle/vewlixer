MEmu := "Emma 02"
MEmuV := "v1.18"
MURL := ["http://www.emma02.hobby-site.com/"]
MAuthor := ["brolly"]
MVersion := "2.0.3"
MCRC := "6C118371"
iCRC := "69C1E8DA"
MID := "635038268887179980"
MSystem := ["RCA Studio II","Soundic Victory MPT-02"]
;----------------------------------------------------------------------------
; Notes:
; Best way to configure controls is to run Emma 02.exe directly so you can access the UI 
; then go to File->Change Data Directory and browse for the data folder inside your emulator folder
; then press Move&Save. If you get any errors make sure you go to %APPDATA%\Emma 02 and move any files 
; that might still be in there to the data folder inside the emulator folder.
; This setting is stored in the registry under HKEY_CURRENT_USER\Software\Marcel van Tongeren\Emma 02\DataDir
; Finally close and restart Emma 02 to make sure the settings will be loaded properly.
; 
; It's highly suggested to do this so you can run the emulator in portable mode (module's default, but can be changed 
; through a RLUI setting). In this mode the emulator will always use that data folder. By doing this you will be 
; telling the emulator to use this same folder when starting in GUI mode as well.
;
; Then edit controls using the Key Map button inside the tab for each particular system.
;
; To run the built-in games create txt files with the correct names and put them on your roms folder
; Built-in games require pressing a specific button on the controller in order to start, so make sure you edit 
; the keys on the module settings to match your own configuration if you change the default ones.
; Most of the games require you to press a button to start the game, like 1 or 2 (refer to the game's manual).
; The game screen will be black until you do.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

mType := Object("RCA Studio II","studio","Soundic Victory MPT-02","victory")
ident := mType[systemName]	; search object for the systemName identifier
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Emma 02 module: " . moduleName)

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
PortableMode := IniReadCheck(settingsFile, "Settings", "PortableMode","true",,1)
A1Key := IniReadCheck(settingsFile, "Settings", "A1Key","1",,1)
A2Key := IniReadCheck(settingsFile, "Settings", "A2Key","2",,1)
A3Key := IniReadCheck(settingsFile, "Settings", "A3Key","3",,1)
A4Key := IniReadCheck(settingsFile, "Settings", "A4Key","4",,1)
A5Key := IniReadCheck(settingsFile, "Settings", "A5Key","5",,1)

hideEmuObj := Object("ahk_class wxWindowNR",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, sevenZExtractPath)

If RegExMatch(romExtension,"i)" . sevenZFormatsRegEx)
	ScriptError(MEmu . " only supports extracted roms. Please extract your roms or turn on 7z for this system as the emu is being sent this extension: """ . romExtension . """")

BezelStart()

If (PortableMode = "true")
	options := "-p"

options := options . (If Fullscreen = "true" ? " -f" : "") . " -u -c=" . ident

HideEmuStart()	; This fully ensures windows are completely hidden even faster than winwait

Run(executable . " " . options . " -s """ . (If romExtension = .txt ? "" : romPath . "\" . romName . romExtension) . """", emuPath)

WinWait("ahk_class wxWindowNR")
WinWaitActive("ahk_class wxWindowNR")

;Built-In Games require a button press for selection
;Make sure you change the keys below to match your own configuration!
If (romExtension = ".txt")
{
	; SetKeyDelay(50)
	Sleep, 1000 ;Increase if game doesn't start automatically
	If RegExMatch(romName,"i)Doodle")
		SendCommand(A1Key)	; Press 1 on P1 controller
	If RegExMatch(romName,"i)Patterns")
		SendCommand(A2Key)	; Press 1 on P1 controller
	If RegExMatch(romName,"i)Bowling")
		SendCommand(A3Key)	; Press 1 on P1 controller
	If RegExMatch(romName,"i)Freeway")
		SendCommand(A4Key)	; Press 1 on P1 controller
	If RegExMatch(romName,"i)Addition")
		SendCommand(A5Key)	; Press 1 on P1 controller
}

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
	WinClose("ahk_class wxWindowNR")
Return
