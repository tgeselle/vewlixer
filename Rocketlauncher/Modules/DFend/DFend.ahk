MEmu := "DFend"
MEmuV := "v1.3.3"
MURL := ["http://dfendreloaded.sourceforge.net/BetaDownload.html"]
MAuthor := ["djvj"]
MVersion := "2.0.2"
MCRC := "A6813B29"
iCRC := "2A86C83F"
MID := "635038268883456883"
MSystem := ["DOS","Microsoft MS-DOS"]
;----------------------------------------------------------------------------
; Notes:
; Requires DOSBox @ http://www.dosbox.com/ or you can get newer SVN versions on EmuCR
; You can find an Enhanced DOSBox (highly recommended) with many unofficial features on ykhwong's page @ http://ykhwong.x-y.net/
; Set SkipChecks to Rom Only because if you keep your games extracted in the DOSBox's VirtualHD. If games are lept archived and 7z extracts them, keep SkipChecks off.
; The Emulator path in RocketLauncherUI needs to be the folder with the DFend.exe and exe needs to be DFend.exe. Ex: ..\Emulators\DOSBox\D-FendReloadedPortable\App\D-Fend Reloaded\DFend.exe
; If 7z_Enable is true, this module will set your Default Game Location in DFend to match the 7z_Extract_Path from RocketLauncherUI.
; Many old games place save games inside their own dirs, if you use 7z_Enable and 7z_Delete_Temp is true, you will delete these save games. Set 7z_Delete_Temp to false to prevent this.
; Setup all your games in the DFend frontend before you compress them, this module will launch each game using DFend instead of straight DOSBox. This allows for easy editing of DOSBox settings in case they are needed.
; Controls are done via in-game options for each game.
; DOSBox cli parameters: http://www.dosbox.com/wiki/Usage
; Dfend support thread: http://www.vogons.org/viewtopic.php?f=31&t=17415
;
; For fullscreen setting to work, a few things must match:
; DFend profile name and file name must match romName (Press Ctrl+Enter on the game while in DFend)
; If your games are compressed (zip, 7z, rar, etc), the game's fileName must match romName like any other emu
;
; List of multiplayer network dos games: http://web.archive.org/web/19970521185925/http://www.cs.uwm.edu/public/jimu/netgames.html
; GoG IPX list: http://www.gog.com/mix/dos_games_with_ipx_multiplayer
; MobyGames IPX list: http://www.mobygames.com/attribute/sheet/attributeId,82/p,2/
; MobyGames NetBios list: http://www.mobygames.com/attribute/sheet/attributeId,129/
;----------------------------------------------------------------------------
StartModule()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
defaultServerIP := IniReadCheck(settingsFile, "Settings", "Default_Server_IP",,,1)
defaultServerPort := IniReadCheck(settingsFile, "Settings", "Default_Server_Port",,,1)
lastIP := IniReadCheck(settingsFile, "Settings", "Last_IP",,,1)	; does not need to be on the ISD
lastPort := IniReadCheck(settingsFile, "Settings", "Last_Port",,,1)	; does not need to be on the ISD
enableNetworkPlay := IniReadCheck(settingsFile, romName, "Enable_Network_Play","false",,1)
networkExecutable := IniReadCheck(settingsFile, romName, "Network_Executable",,,1)
networkProtocol := IniReadCheck(settingsFile, romName, "Network_Protocol","IPX",,1)	; not used yet

If 7zEnable = true
{	dfendINI := CheckFile(emuPath . "\Settings\DFend.ini")
	IniRead, GameLoc, %dfendINI%, ProgramSets, DefGameLoc
	If ( 7zExtractPath != GameLoc )
		IniWrite, %7zExtractPath%HS\, %dfendINI%, ProgramSets, DefGameLoc
}

; Use the -userconf switch instead of the -conf switch if you want to skip the default config file alltogether.

dosboxProf := CheckFile(emuPath . "\Confs\DOSBox DOS.prof")	; profile name for DOSBox
dfendGameProf := CheckFile(emuPath . "\Confs\" . romName . ".prof")	; profile name must match romName in dfend otherwise error here
IniRead, currentFullScreenGlobal, %dosboxProf%, sdl, fullscreen
IniRead, currentFullScreenGame, %dfendGameProf%, sdl, fullscreen
; Setting Fullscreen setting in ini if it doesn't match what user wants above
If (Fullscreen != "true" && (currentFullScreenGlobal = 1 || currentFullScreenGame = 1)) {
	IniWrite, 0, %dosboxProf%, sdl, fullscreen
	IniWrite, 0, %dfendGameProf%, sdl, fullscreen
} Else If (Fullscreen = "true" && (currentFullScreenGlobal = 0 || currentFullScreenGame = 0)) {
	IniWrite, 1, %dosboxProf%, sdl, fullscreen
	IniWrite, 1, %dfendGameProf%, sdl, fullscreen
}

exeSwapped :=
updateIPX :=
If (enableNetworkPlay = "true") {
	Log("Module - Enabling network mode.",4)
	networkSession :=

	; Possible future support for network games (basic requirements to enable networked games)
	; Some games require a different exe to be launched for network support. Doom for example, you launch ipxsetup.exe instead of doom.exe

	; Gosub, QuestionUserTemp
	MultiPlayerMenu(lastIP, lastPort, networkType)

	; Launch GUI here to get if user wants to play a network or Single Player game
	; If Network, user then chooses to be the client or server
	; If Client, allow user to put in a custom IP and Port. Default will be filled from the module settings from RocketLauncherUI
	; GUI order:
	;	Ask if game should be launched Single player or Multi-Player
	;		If Single, exit GUI and launch normally and set %networkSession% to "false"
	;		If Multi-Player, exit GUI and launch normally and set %networkSession% to "true"
	;			As if this session is a server or client
	;				If Server, set %networkType% to "server" and exit GUI
	;				If Client, set %networkType% to "client"
	;					Show a GUI to fill in the IP address of the Server to connect to. Default IP will be the last used IP from %lastIP%
	;						Show a GUI to fill in the port of the Server to connect to. Default Port will be the last used IP from %lastPort% and exit GUI

	If networkSession = true
	{	IniRead, originalGameExe, %dfendGameProf%, Extra, exe	; Store the original exe in case it needs to be restored on exit
		IniRead, beforeExecution, %dfendGameProf%, ExtraCommands, BeforeExecution	; Store the original Extra Commands

		IniWrite, 1, %dfendGameProf%, ipx, ipx	; enable network
		IniWrite, %networkType%, %dfendGameProf%, ipx, type	; can be client or server
		IniWrite, %networkIP%, %dfendGameProf%, ipx, address	; If client, need to put the address of the server to connect tohere
		IniWrite, %networkPort%, %dfendGameProf%, ipx, port	; If client, need to put the port of the server to connect to here
		
		If (networkType = "client") {	; save last used IP and Port for quicker launching next time
			IniWrite, %networkIP%, %settingsFile%, Settings, Last_IP
			IniWrite, %networkPort%, %settingsFile%, Settings, Last_Port
		}
		If networkExecutable {	; if user set a network executable for this game
			Log("Module - This game requires a different executable to be ran for Multi-Player games. Setting it to run: """ . networkExecutable . """",4)
			exeMod := RegExReplace(originalGameExe, "[\w-]+\..*", networkExecutable)	; swap the original exe out for the network one
			IniWrite, %exeMod%, %dfendGameProf%, Extra, exe	; change the exe of the game to the exe required to launch a multiplayer game
			exeSwapped := 1
		}
		
		ipxClientCommand := "IPXNET CONNECT " . networkIP . " " . networkPort	; command for a client in an IPX network
		ipxServerCommand := "IPXNET STARTSERVER " . networkPort	; command for the server in an IPX network

		; when helper commands are added to a game, they show up in the game's conf profile:
		ipxSessionCommand := If networkType = "client" ? ipxClientCommand : ipxServerCommand
		If !InStr(beforeExecution, "IPXNET") {	; if execution does not contain an IPX command at all
			Log("Module - IPXNET command does not exist at all, adding it into the execution.",4)
			beforeExecutionMod := beforeExecution . ipxSessionCommand	; tack on the IPX command at the end
			updateIPX := 1
		} Else If (InStr(beforeExecution, "IPXNET") && !InStr(beforeExecution, ipxSessionCommand)) {	; if an IPX command exists already, update the IPX command with the correct IP and Port
			Log("Module - IPXNET command exists but is not set to the right IP or Port. Updating it to: " . networkIP . " " . networkPort,4)
			beforeExecutionMod := RegExReplace(beforeExecution, "i)IPXNET[\sA-Za-z0-9\.]*", ipxSessionCommand)	; update BeforeExecution with the correct IPX command for this session
			updateIPX := 1
		} Else	; IPX command is already correct, do not change
			Log("Module - IPXNET command already configured correctly.",4)

		If updateIPX {
			Log("Module - IPXNET command updated to match this session in: " . dosboxProf,4)
			IniWrite, %beforeExecutionMod%, %dfendGameProf%, ExtraCommands, BeforeExecution	; write updated BeforeExecution commands to conf
		}
	}
}

hideEmuObj := Object("DOSBox ahk_class SDL_app",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later

; 7z(romPath, romName, romExtension, 7zExtractPath) ; 7z not supported yet
; 7Z SUPPORT IS NEW FOR V1.3, NEED TO TEST AND FINISH THIS MODULE
; Would need to do a regexreplace to change the relativepaths to our new ones in the conf files to support 7z:
; [Extra]
; Exe=.\VirtualHD\SimCity 2000\sc2vesa.bat
; Setup=.\VirtualHD\SimCity 2000\install.exe
; 0=.\VirtualHD\;Drive;C;false;

HideEmuStart()
Run(executable . " """ . romName . """", emuPath)

WinWait("DOSBox ahk_class SDL_app")
WinWaitActive("DOSBox ahk_class SDL_app")
Sleep, 1000 ; DOSBox gains focus before it goes fullscreen, this prevents HS from flashing back in due to this

HideEmuEnd()
FadeInExit()
Process("WaitClose", "DOSBox.exe")
; 7zCleanUp()

If exeSwapped {
	Log("Module - Restoring the original executable for """ . romName . """",4)
	IniWrite, %originalGameExe%, %dfendGameProf%, Extra, exe	; restore the original exe for single player
}
If updateIPX {
	Log("Module - Restoring the original BeforeExecution commands for """ . romName . """",4)
	IniWrite, %beforeExecution%, %dfendGameProf%, ExtraCommands, BeforeExecution	; restore original BeforeExecution commands
}

FadeOutExit()
ExitModule()


QuestionUserTemp:
	Gui +OwnDialogs
	MsgBox, 262148, Question, Do you want to play Multi-Player?, 10
	IfMsgBox Yes
	{	networkSession := "true"
		MsgBox, 262148, Question, Are you acting as the Server?, 10
		IfMsgBox Yes
		{	networkType := "server"
			Return
		} Else {
			networkType := "client"
			InputBox, networkIP, Server IP Address, Please enter the IP Address of the Server,,,,,,,, %lastIP%
			InputBox, networkPort, Server Port, Please enter the Port of the Server,,,,,,,, %lastport%
			Return
		}
	} Else {
		networkSession := "false"
		Return
	}
Return

RestoreEmu:
	Send, !{Enter}
Return

CloseProcess:
	FadeOutStart()
	WinClose("DOSBox ahk_class SDL_app")
Return



; DOSBOX NETWORKING (from 2004)
; I. Introduction 

; More recent versions of DosBox have had virtual modem support, and as of the writing of this guide, the CVS contains virtual IPX support. Virtual modem support emulates modem connectivity over the Internet. This makes it possible for people to play old DOS modem-based multiplayer games over the Internet, no extra hardware required. The virtual modem also effectively turns DOS BBS software like PC-Link, Qmodem and Ripterm into a Telnet client. This allows DOS modem software to connect to bulletin boards now made available over the Internet. While the virtual modem is limited to two DosBox sessions/individuals connected at one time, the virtual IPX support makes games that supported several connected players possible. 

; II. Virtual Modem Support 

; The virtual modem has been designed to simulate a modem as closely as possible. Like real modems, the virtual modem uses a COM port assigned through the dosbox.conf file. The virtual modem also makes use of the Hayes® AT command set to issue commands to the modem. The following is an example entry in the dosbox.conf file for modem configuration: 

; [modem] 
; modem=true 
; comport=2 
; listenport=23 

; “modem=true” enables the modem emulation. To disable the emulation change it to read “modem=false”. DosBox has two COM ports, 1 and 2. Depending on the software compatibility, you may need to change this to 1, though the default setting, as shown here, should work in most cases. Finally, listenport sets the port that listens for incoming DosBox modem calls. Port 23 is typically the telnet port. For simplicity, leaving this value as is should provide for the easiest setup once in DosBox. 

; Once the modem is enabled in DosBox, one uses it as you would a regular modem, with a few exceptions. The following AT commands are valid with the DosBox Virtual Modem: 

; ATDT 

; This is the standard dialing command for a modem. To connect to another computer, this should be the host name or IP address. For example ATDT127.0.0.1 and ATDTbob.internet.com are valid entries. Finally (this feature is only available in the CVS), one can dial by entering a pure stream of numbers. ATDT127000000001 is the equivalent to ATDT127.0.0.1. This 

; ATA 

; This command answers an incoming connect request. On receiving an incoming call, the modem will write out “RING” and a telephone ring will be heard. Typing ATA will finalize the connection and the two DosBox sessions should be connected. 

; ATS0 

; ATS0 is the auto-answer parameter. Typing “ATS0=1” makes DosBox auto-answer any incoming calls. Typing “ATS0=0” (the default) disables auto-answer. 

; ATE 

; ATE0 turns character echo off, where as ATE1 turns character echo on. This is enabled before a connection. On connection, echo is disabled. 

; ATNET 

; (As of this writing, this function is only available in the CVS) “ATNET1” tells DosBox you are connecting to a Telnet session. “ATNET0” (the default) tells DosBox you are connecting to another DosBox session. This option is useful to ensure data are transmitted properly over the respective connections. 

; ATI 

; ATI3 and ATI4 are simple information commands, only present because they are present in nearly all real modems as well. 

; * It should be noted that the virtual modem exists only as a way to connect modem-based DOS programs through the Internet. As of this writing, there is no direct modem access on any platform. 

; III. IPX Networking Support 

; The IPX networking emulation exists for pretty much the same reason as the modem emulation. All of the IPX networking is managed through the internal DosBox program IPXNET. For help on the IPX networking from inside DosBox, type “IPXNET HELP” (without quotes) and the program will list out the commands and relevant documentation. 

; With regard to actually setting up a network, one system needs to be the server. To set this up, in a DosBox section, one should type “IPXNET STARTSERVER” (without the quotes). The server DosBox session will automatically add itself to the virtual IPX network. In turn, for every other computer that should be part of the virtual IPX network, you’ll need to type “IPXNET CONNECT <computer host name or IP>”. For example, if your server is at bob.dosbox.com, you would type “IPXNET CONNECT bob.dosbox.com” on every non-server system. The following is an IPXNET command reference: 

; IPXNET CONNECT 

; IPXNET CONNECT opens a connection to an IPX tunneling server running on another DosBox session. The "address" parameter specifies the IP address or host name of the server computer. One can also specify the UDP port to use. By default IPXNET uses port 213, the assigned IANA port for IPX tunneling, for its connection. 

; The syntax for IPXNET CONNECT is: 
; IPXNET CONNECT address <port> 

; IPXNET DISCONNECT 

; IPXNET DISCONNECT closes the connection to the IPX tunneling server. 

; The syntax for IPXNET DISCONNECT is: 
; IPXNET DISCONNECT 

; IPXNET STARTSERVER 

; IPXNET STARTSERVER starts and IPX tunneling server on this DosBox session. By default, the server will accept connections on UDP port 213, though this can be changed. Once the server is started, DosBox will automatically start a client connection to the IPX tunneling server. 

; The syntax for IPXNET STARTSERVER is: 
; IPXNET STARTSERVER <port> 

; IPXNET STOPSERVER 

; IPXNET STOPSERVER stops the IPX tunneling server running on this DosBox\nsession. Care should be taken to ensure that all other connections have terminated as well since stopping the server may cause lockups on other machines still using the IPX tunneling server.	

; The syntax for IPXNET STOPSERVER is: 
; IPXNET STOPSERVER 

; IPXNET PING 

; IPXNET PING broadcasts a ping request through the IPX tunneled network. In response, all other connected computers will respond to the ping and report the time it took to receive and send the ping message.	

; The syntax for IPXNET PING is: 
; IPXNET PING 

; IPXNET STATUS 

; IPXNET STATUS reports the current state of this DosBox's sessions IPX tunneling network. For a list of the computers connected to the network use the IPXNET PING command. 

; The syntax for IPXNET STATUS is: 
; IPXNET STATUS 
