MEmu := "ZiNc"
MEmuV := "v1.1"
MURL := ["http://www.emulator-zone.com/doc.php/arcade/zinc.html"]
MAuthor := ["djvj"]
MVersion := "2.0.6"
MCRC := "8883434E"
iCRC := "9302090C"
MID := "635038268938302527"
MSystem := ["ZiNc"]
;----------------------------------------------------------------------------
; Notes:
; Script relies on a zinc.cfg in the emu dir which contains all the parameters sent to the emu
; This is made for you by using Aldo's ZiNc Front-End v2.2.
; Zinc uses numbers, not romnames to choose what game to load. The module does the remapping for you so your database should consist of proper short rom names, not numbers.
; This module uses this database: http://pastebin.com/xSWdwTaq
; If your Front End doesn't use xml, you will have to adapt your FE's db to match those names.
;
; This module supports both numbered and non-numbered databases. If you use a numbered one make sure you set skipchecks to Rom Only.
; If you want to use per game specific controller configurations, simply put the .cfg files in a folder named Controls in your emulator folder and name the files after 
; the game name.
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("ZiNc","WinZincWnd"))	; instantiate primary emulator window object
emuConsoleWindow := new Window(new WindowTitle("ZiNc","ConsoleWindowClass"))

; The object controls how the module remaps your romNames to the integers you have to send to Zinc. For example, you send Zinc "1", and it launches "starglad.zip" in your rom path
romType := Object("aquarush","63","beastrzb","26","beastrzr","27","bldyror2","28","brvblade","29","cbaj","67","danceyes","39","doapp","68","dunkmnia","52","dunkmnic","53","ehrgeiz","60","fgtlayer","59","ftimpcta","36","gdarius","37","gdarius2","38","glpracr3","65","hvnsgate","71","hyperath","56","jgakuen","16","kikaioh","20","mfjump","70","mgcldtex","33","mrdrillr","62","myangel3","42","pacapp","64","pbball96","57","plsmaswd","13","primglex","54","psyforce","31","psyforcj","30","psyfrcex","32","raystorj","34","raystorm","35","rvschola","15","rvschool","17","sfex","2","sfex2","8","sfex2j","9","sfex2p","10","sfex2pa","12","sfex2pj","11","sfexa","4","sfexj","3","sfexp","5","sfexpj","7","sfexpu1","6","shiryu2","18","shngmtkb","66","sncwgltd","25","souledga","49","souledgb","50","souledge","51","starglad","1","stargld2","14","starswep","41","strider2","19","susume","58","techromn","21","tekken","45","tekken2","48","tekken2a","47","tekken2b","46","tekken3","61","tekkena","44","tekkenb","43","tgmj","24","tondemo","69","ts2","22","ts2j","23","weddingr","55","xevi3dg","40")

If romName is integer
{
	RLLog.Info("Module - Numbered Rom Detected")
	ident := romName
	If (romName < 1 || romName > 71)
		ScriptError("Your romName is: " . romName . "`nNumbered roms must be within 1 and 71")
} Else {
	RLLog.Info("Module - Non-Numbered Rom Detected")
	ident := romType[romName]	; search 1st array for the romName identifier Zinc uses
	If !ident
		ScriptError("Your romName is: " . romName . "`nIt is not one of the known supported roms for this Zinc module: " . moduleName)
}

Fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
InsertDiskErrorFix := moduleIni.Read("Settings", "InsertDiskErrorFix","false",,1)
SlowGeometry := moduleIni.Read(RomName, "SlowGeometry","false",,1)
SoundFilterEnabled := moduleIni.Read(RomName, "SoundFilterEnabled","false",,1)
StereoExciterEnabled := moduleIni.Read(RomName, "StereoExciterEnabled","false",,1)
ControllerPlugin := moduleIni.Read(RomName, "ControllerPlugin","",,1)
RendererPlugin := moduleIni.Read(RomName, "RendererPlugin","",,1)

CheckFile(emuPath . "\zinc.cfg","Could not find " . emuPath . "\zinc.cfg. Please run the zincFE to set your options so this file is created for you.")
rendFile := CheckFile(emuPath . "\renderer.cfg")
rendCFG := LoadProperties(rendFile)	; load the config into memory
currentFullScreen := ReadProperty(rendCFG,"FullScreen")	; read current fullscreen state

If (InsertDiskErrorFix = "true")
	MiscUtils.SetErrorMode(2)

BezelStart("FixResMode")

; Setting Fullscreen setting in cfg if it doesn't match what user wants above
If (Fullscreen != "true" And currentFullScreen = 1) {
	WriteProperty(rendCFG,"FullScreen", 0, 1)	; adds spaces around =
	SaveProperties(rendFile,rendCFG)	; save rendFile to disk
} Else If (Fullscreen = "true" And currentFullScreen = 0) {
	WriteProperty(rendCFG,"FullScreen", 1, 1)	; adds spaces around =
	SaveProperties(rendFile,rendCFG)	; save rendFile to disk
}

zincRomPath := " --roms-directory=""" . romPath . """"	; sends the correct rompath, no matter what the user sets in the cfg
zincParams := " --use-config-file=zinc.cfg"

If (SlowGeometry = "true")
	zincParams .= " --use-slow-geometry=yes"
If (SoundFilterEnabled = "true")
	zincParams .= " --sound-filter-enable=yes"
If (StereoExciterEnabled = "true")
	zincParams .= " --sound-stereo-exciter=yes"	
If (ControllerPlugin)
{
	conPluginFile := new File(emuPath . "\" . ControllerPlugin)
	If conPluginFile.Exist()
		zincParams .= " --controller=""" . ControllerPlugin . """"
}
If (RendererPlugin)
{
	renPluginFile := new File(emuPath . "\" . RendererPlugin)
	If renPluginFile.Exist()
		zincParams .= " --renderer=""" . RendererPlugin . """"
}
gameConfigFile := new File(emuPath . "\Controls\" . romName . ".cfg")
If gameConfigFile.Exist()	; use a specific controller config file if it exists
	zincParams .= " --use-controller-cfg-file=""" . gameConfigFile.FileFullPath . """"

hideEmuObj := Object(emuConsoleWindow,0,emuPrimaryWindow,1)
HideAppStart(hideEmuObj,hideEmu)

PrimaryExe.Run(ident . zincRomPath . zincParams)	; putting the rompath before the cfg ensures the settings overwrite what's set in the zinc.cfg

emuConsoleWindow.Wait()	; wait for console window to be created and then hide it
emuConsoleWindow.Set("Transparent","On")	; force the console window to be transparent
emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")
FadeOutExit()
BezelExit()
ExitModule()


SaveFile(text,file) {
	FileDelete, %file%
	FileAppend, %text%, %file%
}

HaltEmu:
	disableSuspendEmu := "true"
	KeyUtils.Send("{End down}{End up}")
Return
RestoreEmu:
	WinActivate, ahk_id  %emulatorID%
	TimerUtils.Sleep(200)
	KeyUtils.Send("{End down}{End up}")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
