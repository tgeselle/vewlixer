MCRC := "2142F241"
MVersion := "1.1.4"

7z(ByRef _7zP, ByRef _7zN, ByRef _7zE, ByRef _7zExP,call:="", AttachRomName:=true, AllowLargerFolders:=false){
	Global sevenZEnabled,sevenZFormats,sevenZFormatsNoP,sevenZFormatsRegEx,sevenZPath,sevenZAttachSystemName,sevenZTimedOut,sevenZTimerRunning,romExtensions,skipchecks,romMatchExt,systemName,dbName,MEmu,logLevel
	Global fadeIn,fadeLyr37zAnimation,fadeLyr3Animation,fadeLyr3Type,sevenZTempRomExists,use7zAnimation,romExSize,sevenZ1stRomPath,sevenZRomPath,sevenZPID,sevenZStatus
	Global romMapTable,romMappingFirstMatchingExt,romMenuRomName ;,romMappingEnabled
	Global altArchiveNameOnly,altRomNameOnly,altArchiveAndRomName,altArchiveAndManyRomNames,altRomNamesOnly
	Global fade7zProgressMode,fadeAnimationTimeElapsed,progressBarTimeToMax,FadeInExitDelay
	Static sevenZ1stUse
	If (sevenZEnabled = "true")
	{	old7zP:=_7zP,old7zN:=_7zN,old7zE:=_7zE	; store values sent to 7z for logging
		;If ( romMapTable.MaxIndex() && !_7zN )	; if romMapTable contains a rom and romName not passed
			; msgbox Rom map table exists`nNo rom name passed to 7z`nrom must be in map table so parse all archive types in table and check contents for the alt archive name or for the alt rom named if defined
		; Else If ( romMapTable.MaxIndex() && _7zN )	; if romMapTable contains a rom and romName passed
			; msgbox Rom map table exists`nRom name passed to 7z`nignore map table as rom was passed`, but if archive type`, handle it`, otherwise run rom as is`nNO CHANGES NEEDED TO HANDLE THIS SCENARIO
		; Else If ( !romMapTable.MaxIndex() && _7zN )	; if romMapTable does not contain a rom and romName passed
			; msgbox Rom map table does not exist`nRom name passed to 7z`nHandle rom`, if archive type pass further into 7z else if not`, skip 7z and run rom as is`nNO CHANGES NEEDED TO HANDLE THIS SCENARIO
		; Else If ( !romMapTable.MaxIndex() && !_7zN )	; if romMapTable does not contain a rom and romName not passed
			; msgbox Rom map table does not exist`nNo rom name passed to 7z`nShould never see this error because no rom exists else if we are going to have to error out
		RLLog.Info("7z - Started, " . (If _7zN ? "received " . _7zP . "\" . _7zN . _7zE . ". If rom is an archive, it will extract to " . _7zExP : "but no romName was received"))
		sevenZ1stUse ++	; increasing var each time 7z is used
		sevenZStatus := ""	; this var keeps track of where 7z is inside this function. This is needed so other parts of RocketLauncher stay in sync and don't rush through their own routines
		sevenZRunning := ""
		sevenZFinished := ""
		
		If (_7zE != "" && !InStr(sevenZFormats,_7zE)) {
			RLLog.Info("7z - This file is not an archive and does not need to be extracted.")
			useNon7zAnimation := 1
		}

		Loop, Parse, romExtensions, |	; parse out 7zFormat extensions from romExtensions so the dll doesn't have to parse as many
		{	If !RegExMatch(A_LoopField,"i)" . sevenZFormatsNoP)
			{	extIndex ++	; index only increases on valid rom type extensions
				romExtFound := 1
				romTypeExtensions .= (If extIndex > 1 ? "|":"") . A_LoopField
			}
		}
		If (!romExtFound and skipChecks = "false")
			ScriptError("You did not supply any valid rom extensions to search for in your compressed roms. Please turn off 7z support or add at least one rom extension to Rom_Extension: """ . romExtensions . """. If this archive has no roms with a standard romName inside, you may need to set Skip Checks to ""Rom Extension.""",10)
; msgbox romMenuRomName: %romMenuRomName%`nromFromDLL: %romFromDLL%`ndllRomPath: %dllRomPath%`ndllName: %dllName%`ndllExt: %dllExt%`n7zExP: %_7zExP%`nsevenZAttachSystemName: %sevenZAttachSystemName%`n_7zP: %_7zP%`n7zN: %_7zN%`n7zE: %_7zE%`nsevenZExPCheck: %sevenZExPCheck%`nromExSize: %romExSize%`nsevenZExPCheckSize: %sevenZExPCheckSize%`nromFound: %romFound%
; ExitApp
		If (romMapTable.MaxIndex() && !_7zN) {	; if romMapTable contains a rom and romName not passed, we must search the rom map table for known roms (defined from map ini or same as archive name) and stop on first found. This method is from a mapped rom not from the Rom Launch Menu.
			RLLog.Debug("7z - Using romTable method because a romTable exists and no romName provided")
			sevenZUsed := 1	; flag that we used 7z for this launch
			Loop % romMapTable.MaxIndex()	; Loop through all found rom map inis
			{	altArchiveFullPath := romMapTable[A_Index,"romPath"] . "\" . romMapTable[A_Index,"romName"] . "." . romMapTable[A_Index,"romExtension"], romMapIni := romMapTable[A_Index,1] ;, romMapKey := "Alternate_Rom_Name"
				firstAltArchiveFullPath := altArchiveFullPath	; storing this so it can be used if skipchecks is enabled and there are multiple paths found, we only want to send the first in this scenario
				RLLog.Debug("7z - Found a path to a previously found rom in romMapTable: """ . altArchiveFullPath . """")
				IniRead, altRomName, %romMapIni%, %dbName%, Alternate_Rom_Name
				If (altRomName = "" || altRomName = "ERROR")	; if multiple alt roms were defined, do a check if user defined the key with "_1"
					IniRead, altRomName, %romMapIni%, %dbName%, Alternate_Rom_Name_1
				If !(altRomName = "" || altRomName = "ERROR")
					RLLog.Debug("7z - Mapping ini contains an Alternate_Rom_Name of """ . altRomName . """")
				SplitPath, altArchiveFullPath,, _7zP, _7zE, _7zN	; assign vars to what is needed for the rest of 7z. This is where we define romPath, romName, and romExtension when none were provided to 7z because we used a map table instead.
				_7zE := "." . _7zE
				If romFromDLL := RLObject.findFileInZip(altArchiveFullPath, If (altRomName != "" && altRomName != "ERROR") ? altRomName : _7zN, romTypeExtensions)	; if altRomName is a valid name, search for it, otherwise search for the 7zN
				{	RLLog.Debug("7z - DLL found rom inside archive using ""findFileInZip"": """ . romFromDLL . """")
					foundRom := 1
					Break
				} Else If (romMappingFirstMatchingExt = "true")		; if we didn't find an exact romName, settle on finding one that at least matches the first matching extension
				{	If romFromDLL := RLObject.findByExtension(altArchiveFullPath, romTypeExtensions)
					{	foundRom := 1
						Break	; break on first found rom and move on
					}
				}
			}
			If foundRom {
				RLLog.Info("7z - Loading Mapped Rom: """ . romFromDLL . """ found inside """ . _7zP . "\" . _7zN . _7zE . """")
				romFromRomMap := 1
				romIn7z := "true"	; avoid a duplicate check later
			} Else If (skipChecks != "false")	; this scenario is when a rom map is used to load an archive with no valid  rom name or extension, like scummvm compressed roms, and relinking those roms to a different name
			{	SplitPath, firstAltArchiveFullPath,, _7zP, _7zE, _7zN	; assign vars to what is needed for the rest of 7z. This is where we define romPath, romName, and romExtension when none were provided to 7z because we used a map table instead.
				_7zE := "." . _7zE
				RLLog.Debug("7z - A matching rom was not found inside the archive, but skipChecks is set to " . skipChecks . ", so continuing with extraction of the first found rom in the table: " . firstAltArchiveFullPath)
			} Else
				ScriptError("Scanned all defined ""Alternate_Archive_Name"" and no defined ""Alternate_Rom_Name"" found in any provided Rom Map ini files for """ . dbName . """")

		} Else If romMenuRomName {	; if rom came from the rom map menu
			RLLog.Debug("7z - Using Rom Map Menu method because the Launch Menu was used for this rom: """ . romMenuRomName . """")
			sevenZUsed := 1	; flag that we used 7z for this launch
			SplitPath, romMenuRomName,,,rmExt, rmName	; roms in map table do not always have an extension, like when showing roms from the map ini instead of all in the archive. If it does, use it to find the rom in the archive faster, if it doesn't, search all defined romExtensions
			IfNotInString, romTypeExtensions, %rmExt%
			{	RLLog.Debug("7z - The rom Ext """ . rmExt . """ was not found in """ . romTypeExtensions . """")
				rmName := rmName . "." . rmExt	; If rom "extension" don't match romTypeExtension, this is probably not an extension but part of the romname
				rmExt := ""
			}
			; msgbox % _7zP . "\" . _7zN . _7zE
			If romFromDLL := RLObject.findFileInZip(_7zP . "\" . _7zN . _7zE, rmName, If rmExt ? rmExt : romTypeExtensions)	; If rmExt exists, search for it, otherwise search for the all romTypeExtensions. Only searching for rmExt will speed up finding our rom
			{	RLLog.Debug("7z - DLL found rom inside archive using ""findFileInZip"": """ . romFromDLL . """")
				romFromRomMap := 1
				romIn7z := "true"	; avoid a duplicate check later
			} Else	; if rom was not found in archive
				ScriptError("Scanned all defined ""Alternate_Archive_Name"" and could not find the selected game " . romMenuRomName . " in any provided Rom Map ini files for " . dbName)

		} Else If RegExMatch(_7zE,"i)" . sevenZFormatsRegEx)	; Not using Rom Mapping and if provided extension is an archive type
		{	RLLog.Debug("7z - Using Standard method to extract this rom")
			sevenZUsed := 1	; flag that we used 7z for this launch
			RLLog.Debug("7z - """ . _7zE . """ found in " . sevenZFormats)
			If !romFromRomMap {	; do not need to check for rom extensions if alt rom was already scanned in the above dll "findFileInZip"
				CheckFile(_7zP . "\" . _7zN . _7zE,"7z could not find this file, please check it exists:`n" . _7zP . "\" . _7zN . _7zE)
				; If skipChecks = false	; the following extension checks are bypassed with setting skipChecks to any option that will skip Rom Extensions (all of them except when skipchecks is disabled)
				; {
					If romFromDLL := RLObject.findFileInZip(_7zP . "\" . _7zN . _7zE, _7zN, romTypeExtensions)	; check for _7zN inside the archive
					{	romIn7z := "true"	; avoid a duplicate check later
						RLLog.Info("7z - Archive name matches rom name`; DLL found rom inside archive using ""findFileInZip"": """ . romFromDLL . """")
					} Else If (romMatchExt != "true" && skipChecks = "false")	; do not error if skip checks is set
						ScriptError("Could not find """ . _7zN . """ inside the archive with any defined Rom Extensions. Check if you are missing the correct Rom Extension for this rom for " . MEmu . "'s Extensions`, enable Rom_Match_Extension`, or correct the file name inside the archive.")
					If !romIn7z {	; if we didn't find an exact romName, settle on finding one that at least matches the first matching extension
						If romFromDLL := RLObject.findByExtension(_7zP . "\" . _7zN . _7zE, romTypeExtensions)
						{	romIn7z := "true"	; avoid a duplicate check later
							RLLog.Warning("7z - Archive name DOES NOT MATCH rom name`; DLL found rom inside archive using ""findByExtension"": " . romFromDLL)
						}
					}
				; }
			}
		} Else If useNon7zAnimation
			RLLog.Info("7z - Skipping main processing.")
		Else
			RLLog.Warning("7z - Unhandled scenario, please report this and post your troubleshooting log")

		If (romIn7z = "true" || (skipchecks != "false" && sevenZUsed))
		{	SplitPath, romFromDLL,,dllRomPath,dllExt,dllName
			If (sevenZAttachSystemName = "true")
				RLLog.Debug("7z - Attaching the system name """ . systemName . """ to the extracted path")
			sevenZRomPath := _7zExP . (If sevenZAttachSystemName = "true" ? "\" . systemName : "") . (If AttachRomName ? "\" . _7zN : "")	; sevenZRomPath reflects the sevenZExtractPath + the rom folder our rom will be extracted into. This is used for cleanup later so RocketLauncher knows what folder to remove
			sevenZExPCheck := sevenZRomPath . (If dllRomPath ? "\" . dllRomPath : "")	; If the archive contains a path/subfolder to the rom we are looking for, add that to the path to check
			romExSize := RLObject.getZipExtractedSize(_7zP . "\" . _7zN . _7zE)	; Get extracted Size of rom for Fade so we know when it's done being extracted or so we can verify the rom size of extracted folders with multiple roms
			RLLog.Debug("7z - Invoked COM Object, ROM extracted size: " . romExSize . " bytes")

			If (skipchecks != "false")
				RLLog.Warning("7z - Following paths in log entries may not be accurate because SkipChecks is enabled! Do not be alarmed if you see invalid looking paths when Skip Checks is required for this system.")
			
			If (AttachRomName || dllRomPath) {
				sevenZExSizeCheck := sevenZExPCheck
			} Else {	; AttachRomName=false AND dllRomPath is empty (rom not found inside the archive)
				RLLog.Debug("7z - Checking for root folder in archive " . _7zP . "\" . _7zN . _7zE)
				rootFolder := RLObject.getZipRootFolder(_7zP . "\" . _7zN . _7zE) ; Check if compressed archive only contains a single folder as the root and if so use that for checking the extraction size, if we don't do this size of the whole 7z_Extract_Path folder will be calculated which means the file will always be extracted as the next loop will produce the wrong file size
				RLLog.Debug("7z - Root folder checking returned """ . rootFolder . """")
				sevenZExSizeCheck := If rootFolder ? sevenZExPCheck . "\" . rootFolder : sevenZExPCheck
				; msgbox sevenZRomPath: %sevenZRomPath%`n7zExP: %_7zExP%`nsevenZExPCheck: %sevenZExPCheck%`nrootFolder: %rootFolder%`n7zExSizeCheck: %sevenZExSizeCheck%`n7zExSizeCheck: %sevenZExSizeCheck%`nromFromDLL: %dllRomPath%`ndllName: %dllName%`ndllExt: %dllExt%`ndllRomPath: %dllRomPath%`nAttachRomName: %AttachRomName%`nsevenZAttachSystemName: %sevenZAttachSystemName%
			}

			RLLog.Debug("7z - Checking if this archive has already been extracted in " . sevenZExSizeCheck)
			If FileExist(sevenZExSizeCheck)	; Check if the rom has already been extracted and break out to launch it
			{	Loop % sevenZExSizeCheck . "\*.*",,1
					sevenZExPCheckSize += %A_LoopFileSize%
				RLLog.Debug("7z - File already exists in " . sevenZExSizeCheck . " with a size of: " . sevenZExPCheckSize . " bytes")
			} Else
				RLLog.Debug("7z - File does not already exist in " . sevenZExSizeCheck . "`, proceeding to extract it.")

			; msgbox romMenuRomName: %romMenuRomName%`nromFromDLL: %romFromDLL%`ndllRomPath: %dllRomPath%`ndllName: %dllName%`ndllExt: %dllExt%`n7zExP: %_7zExP%`nsevenZAttachSystemName: %sevenZAttachSystemName%`n7zP: %_7zP%`n7zN: %_7zN%`n7zE: %_7zE%`nsevenZExPCheck: %sevenZExPCheck%`nromExSize: %romExSize%`nsevenZExPCheckSize: %sevenZExPCheckSize%`nromFound: %romFound%
			; difference:=sevenZExPCheckSize-romExSize
			; msgbox, rom: %_7zP%\%_7zN%%_7zE%`nrom size from dll getZipExtractedSize: %romExSize%`nrom size alread on disk: %sevenZExPCheckSize%`ndifference: %difference%
			If (romExSize && sevenZExPCheckSize && (If AllowLargerFolders ? (romExSize <= sevenZExPCheckSize) : (romExSize = sevenZExPCheckSize)))	; If total size of rom in archive matches the size on disk, good guess the extracted rom is complete and we don't need to re-extract it again. If the system allows for larger extract path than the currently extracting game, like in dos games where there may be saved info made in the folder, allow the already extracted game to be larger than the archived game. AllowLargerFolders must be set to allow this behavior.
			{	_7zP := sevenZExPCheck
				_7zE := "." . dllExt
				_7zN := dllName					; set romName to the found rom from the dll
				romFound := "true"				; telling rest of function rom found so it exists successfully and to skip to end
				sevenZTempRomExists := "true"	; telling the animation that the rom already exists so it doesn't try to show a 7z animation
				; RLLog.Debug("7z - TESTING 1 -- _7zP: " . _7zP)
				; RLLog.Debug("7z - TESTING 1 -- _7zN: " . _7zN)
				; RLLog.Debug("7z - TESTING 1 -- _7zE: " . _7zE)
				RLLog.Debug("7z - Breaking out of 7z to load existing file")
				If (fadeIn = "true")
				{	RLLog.Debug("7z - FadeIn is true, but no extraction needed as it already exists in 7z_Extract_Path. Using Fade_Layer_3_Animation instead.")
					useNon7zAnimation := 1
				}
			} Else {
				Clipboard := sevenZExPCheckSize
				sizeDiff := If (romExSize > sevenZExPCheckSize) ? romExSize - sevenZExPCheckSize : sevenZExPCheckSize - romExSize
				RLLog.Debug("7z - Calculated a difference of " . sizeDiff . " bytes, so this file will be extracted")
			}
		} Else If !RegExMatch(_7zE,"i)" . sevenZFormatsRegEx)	; only need this condition if using the standard 7z method and provided rom doesnt need 7z to load
		{	RLLog.Info("7z - Provided rom extension """ . _7zE . """ is not an archive type, turning off 7z and running rom directly.")
			sevenZEnabled := "false"	; need to tell the animation to load a non-7z animation
			If (fadeIn = "true")
			{	RLLog.Debug("7z - FadeIn is true, but no extraction needed for this rom. Using Fade_Layer_3_Animation instead.")
				useNon7zAnimation := 1
			}
		}

		; This section is seperate because I use a couple unique conditions in the above block of code, where the below code would be duplicated if it was moved up.
		; If ((romIn7z = "true" || skipchecks != "false") && !romFound) { ; we found the rom in the archive or we are skipping looking alltogether
		If ((romIn7z = "true" || (skipchecks != "false" && sevenZUsed)) && romFound != "true") {
			RLLog.Debug("7z - " . (If romIn7z = "true" ? "File found in archive" : "Skipchecks is enabled`, and set to " . skipChecks . " continuing to extract rom."))
			; _7zExP := _7zExP . "\" . (If sevenZAttachSystemName = "true" ? systemName . "\" : "") . _7zN	; unsure what this was for but its causing sevenZExPCheck to keep adding on path names on each loop

			pathLength := StrLen(sevenZExPCheck . "\" . dllName . "." . dllExt)	; check length and error if there will be a problem.
			If pathLength > 255
				ScriptError("If you extract this rom, the path length will be " . pathLength . "`, exceeding 255 characters`, a Windows limitation. Please choose a shorter 7z_Extract_Path or shorten the name of your rom.")
			Else
				RLLog.Debug("7z - Extracted path of rom will be " . pathLength . " in length and within the 255 character limit.")

			If !InStr(sevenZRomPath,"\\") {
				SplitPath, sevenZRomPath,,outDir,,,outDrive	; grabbing the outDrive because sometimes supplying just the sevenZRomPath or outDir to check for space doesn't always return a number
				If !FileExist(sevenZRomPath) {
					FileCreateDir, %sevenZRomPath%
					If ErrorLevel
						ScriptError("There was a problem creating this folder to extract your archive to. Please make sure the drive " . outDrive . " exists and can be written to: """ . sevenZRomPath . """")
				}
				DriveSpaceFree, sevenZFreeSpace, %outDrive%	; get free space in MB of this drive/folder
				If ((sevenZFreeSpace * 1000000) < romExSize)	; if the free space on the drive is less than the extracted game's size, error out
					ScriptError("You do not have enough free space in """ . outdir . """ to extract this game. Please choose a different folder or free up space on the drive. Free: " . sevenZFreeSpace . " MB / Need: " . (romExSize // 1000000) . " MB")
				Else
					RLLog.Info("7z - The sevenZExtractPath has " . sevenZFreeSpace . " MB of free space which is enough to extract this game: " . (romExSize // 1000000) . " MB")
			} Else
				RLLog.Warning("7z - The sevenZExtractPath is a network folder and free space cannot be determined: " . sevenZRomPath)
				
			If (fadeIn = "true" && !call)
			{	RLLog.Debug("7z - FadeIn is true, starting timer to update Layer 3 animation with 7z.exe statistics")
				use7zAnimation := "true"	; this will tell the Fade animation (so progress bar is shown) that 7z is being used to extract a rom
				;SetTimer, UpdateFadeFor7z%zz%, -1	; Create a new timer to start updating Layer 3 of fade. This needs to be a settimer otherwise progress bar gets stuck at 0 during extraction because the thread is waiting for that loop to finish and 7z never starts.
				Gosub, UpdateFadeFor7z%zz%	; Create a new timer to start updating Layer 3 of fade
			} Else If (call = "mg") {	; If 7z was called from MG, we need start updating its progress bar
				RLLog.Info("7z - MG triggered 7z, starting the MG Progress Bar")
				SetTimer, UpdateMGFor7z%zz%, -1
			} Else If (call = "pause") {	; If 7z was called from Pause, we need start updating its progress bar
				RLLog.Info("7z - Pause triggered 7z, starting the Pause Progress Bar")
				SetTimer, Pause_UpdateFor7z%zz%, -1
			}
			If (logLevel >= 4) {	; all debug levels will dump extraction info to log
				RLLog.Debug("7z - Logging is debug or higher, dumping 7z Extraction info to log")
				SetTimer, DumpExtractionToLog, -1
			}
			RLLog.Info("7z - Starting 7z extraction of " . _7zP . "\" . _7zN . _7zE . "  to " . sevenZExSizeCheck)
			sevenZRunning := 1
			7zTimeStart := A_Now
			RunWait, %sevenZPath% x "%_7zP%\%_7zN%%_7zE%" -aoa -o"%sevenZRomPath%", sevenZPID,Hide ; perform the extraction and overwrite all
			If ErrorLevel
			{	If ErrorLevel = 1
					Error := "Non fatal error, file may be in use by another application"
				Else If ErrorLevel = 2
					Error := "Fatal Error. Possibly out of space on drive."
				Else If ErrorLevel = 7
					Error := "Command line error"
				Else If ErrorLevel = 8
					Error := "Not enough memory for operation"
				Else If ErrorLevel = 255
					Error := "User stopped the process"
				Else
					Error := "Unknown 7zip Error"
				ScriptError("7zip.exe Error: " . Error)
			}
			sevenZRunning := ""
			sevenZTimeEnd := A_Now - 7zTimeStart
			sevenZFinished := 1
			RLLog.Info("7z - Finished 7z extraction which took " . sevenZTimeEnd . " seconds")
			sevenZPID := ""	; clear the PID because 7z is not running anymore
			If (FileExist(sevenZExPCheck . "\" . dllName . "." . dllExt) || skipchecks != "false") { ; after extracting, if the rom now exists in our temp dir, or we are skipping looking, update 7zE, and break out
				_7zP := sevenZExPCheck
				_7zE := "." . dllExt
				If (skipChecks != "Rom Extension")
					_7zN := dllName	; update the romName just in case it was different from the name supplied to 7z, never update _7zN if skipChecks is set to Rom Extension
				romFound := "true"
				; _7zN := dllName
				If !RegExMatch(skipChecks,"i)Rom Only|Rom and Emu")
					RLLog.Debug("7z - Found file in " . sevenZExPCheck . "\" . dllName . "." . dllExt)
			} Else { ; after extraction, rom was not found in the temp dir, something went wrong...
				romFound := "false"
				foundExt := "." . dllExt
			}
		}
		If sevenZUsed {
			If !romFound	; no need to error that a rom is not found if we are not supplying a rom to 7z
				ScriptError("No valid roms found in the archive " . _7zN . _7zE . "`nPlease make sure Rom_Extension contains a rom extension inside the archive: """ . romExtensions . """`nIf this is an arcade rom archive with no single definable extension, please try setting Settings->Skip Checks to Rom Only for this system.",10)
			Else If (romFound = "false")	; no need to error that a rom is not found if we are not supplying a rom to 7z
				ScriptError("No extracted files found in " . _7zExP . "`nCheck that you are not exceeding the 255 character limit and this file is in the root of your archive:`n" . _7zN . foundExt,10)
			If sevenZ1stUse = 1	; If this is the first time 7z was used (rom launched from FE), set this var so that 7zCleanup knows where to find it for deletion. MultiGame extractions will be stored in the romTable for deletion.
				sevenZ1stRomPath := sevenZExSizeCheck
		} Else {
			RLLog.Info("7z - This rom type does not need 7z: """ . _7zE . """")
			useNon7zAnimation := 1
		}
		If ((useNon7zAnimation && fadeIn = "true") && !mg)		; this got flagged above if 7z is on, but 7z was not used or needed for the current rom. Since the 7z call is after FadeInStart in the module, we need to start call the animation here now.
		{	RLLog.Info("7z - Starting non-7z FadeIn animation.")
			; SetTimer, UpdateFadeForNon7z%zz%, -1	; Create a new timer to start fade non-7z animation because jumping out of a function via gosub does not work
			Gosub, UpdateFadeForNon7z%zz%	; Create a new timer to start fade non-7z animation because jumping out of a function via gosub does not work
			; GoSub, %fadeLyr3Animation%	; still need to provide an animation because the 7z animation won't trigger above
		}
		RLLog.Warning("7z - romPath changed from """ . old7zP . """ to """ . _7zP . """")
		RLLog.Warning("7z - romName changed from """ . old7zN . """ to """ . _7zN . """")
		RLLog.Warning("7z - romExtension changed from """ . old7zE . """ to """ . _7zE . """")
		RLLog.Info("7z - Ended")
	}
	;assuring that fade delays the emulator launch if the user choose a custom progress time higher than what is needed to launch the game
	If (fadeIn = "true" and fade7zProgressMode="custom" and sevenZUsed){
		While (fadeAnimationTimeElapsed < progressBarTimeToMax - FadeInExitDelay) {
			Sleep, 100
			Continue
		}
	}
	Return
	
	DumpExtractionToLog:			
	Process("Wait", "7z.exe", 2)
		If !sevenZTimerRunning {	; if the fade animation did not start the timer, let's start it here
			sevenZTimerRunning := 1
			sevenZTimedOut :=	; reset counter
			SetTimer, SevenZTimeout, 100	; poll 7z.exe every 100ms to see if it's still running
			RLLog.Debug("7z - Starting SevenZTimeout Timer")
		}
		Loop {
			; Updating 7z extraction info
			SetFormat, Float, 3	; don't want to show decimal places in the percentage
			romExPercentageAndFile := RLObject.getExtractionSize(sevenZExSizeCheck, 0)	; Get the current file being extracted and size of the 7z Extract Path - (Extraction Progress (Accurate Method))
			Loop, Parse, romExPercentageAndFile, |	; StringSplit oddly doesn't work for some unknown reason, must resort to a parsing Loop instead
			{
				If A_Index = 1
				{
					romExCurSize := A_LoopField									; Store bytes extracted
					romExPercentage := (A_LoopField / romExSize) * 100	; Calculate percentage extracted
			; tooltip % romExPercentage
				} Else If A_Index = 2
					romExFile := A_LoopField
			}

			; Defining text to be shown
			outputDebugPercentage := % "Extracting file:`t" . romExFile . "`t|`tPercentage Extracted: " . romExPercentage . "%"
			If (logLevel = 10)	; if logging is set to troubleshooting
				ToolTip % "Percentage Extracted: " . romExPercentage . "%"
			RLLog.Debug(outputDebugPercentage)

			; Breaking Loop
			; Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
			; If !ErrorLevel {
			If (sevenZTimedOut >= 200) {	; bar is at 100% or 7z is already closed, so break out
				RLLog.Debug("7z - " . (If romExPercentage >= 100 ? "7z.exe returned a percentage >= 100":"7z.exe is no longer running") . ", assuming extraction is complete")
				Break
			}
			Sleep, 100
		}
		ToolTip
	Return
}

SevenZTimeout:
	Process, Exist, 7z.exe	; This breaks out of 7z.exe If it's no longer running. Sometimes an extraction was very quick or there was an error and we don't want to be stuck in an infinite Loop
	7zerrlvl := ErrorLevel
	If !ErrorLevel
		sevenZTimedOut += 100
	If sevenZTimedOut >= 200
	{	RLLog.Debug("SevenZTimeout - 7z.exe is no longer running")
		sevenZTimerRunning := ""
		SetTimer, SevenZTimeout, Off
	}
Return

7zCleanUp(ExtractedFolder:="") {
	Global romTable,dbName,mgEnabled,pauseEnabled, systemName
	Global sevenZEnabled,sevenZDelTemp,sevenZCanceled,sevenZ1stRomPath,sevenZCleanUpTriggered, sevenZAttachSystemName, sevenZExtractPath, sevenZGamesToKeep, sevenZDeletePerSystem
	Global sevenZEnabled,sevenZDelTemp,sevenZCanceled,sevenZ1stRomPath,sevenZCleanUpTriggered, sevenZAttachSystemName, sevenZExtractPath, sevenZDeletePerSystem
	sevenZDeleteFolder := If ExtractedFolder = "" ? sevenZ1stRomPath : ExtractedFolder
	If (sevenZEnabled = "true" && !sevenZCleanUpTriggered && ( ( (sevenZDelTemp = "true") and (sevenZGamesToKeep="") ) or sevenZCanceled))	; if user wants to delete temp files or user canceled a 7z extraction
	{	RLLog.Info("7zCleanUp - Started")
		sevenZCleanUpTriggered := 1
		romTableExists := IsObject(romTable)	; if romTable was ever created, it would be an object, which is what this checks for
		If ((mgEnabled = "true" || pauseEnabled = "true") && romTableExists)
		{	RLLog.Debug("7zCleanUp - romTable exists and MG or Pause is enabled. Parsing the table to delete any roms that were extracted")
			for index, element in romTable
				If % romTable[A_Index, 19]
				{	FileRemoveDir, % romTable[A_Index, 19], 1	; remove each game that was extracted with 7z
					RLLog.Info("7zCleanUp - Deleted " . romTable[A_Index, 19])
				}
				FileRemoveDir, %sevenZDeleteFolder%, 1 ; still have to remove the rom we launched from HS
				RLLog.Info("7zCleanUp - Deleted " . sevenZDeleteFolder)
		} Else {
			FileRemoveDir, %sevenZDeleteFolder%, 1
			RLLog.Info("7zCleanUp - Deleted " . sevenZDeleteFolder)
		}
		RLLog.Info("7zCleanUp - Ended")
	} Else if sevenZGamesToKeep is number
	{	;Making temp game folders list
		If (sevenZAttachSystemName = "true") {
			if (sevenZDeletePerSystem = "true"){
				Loop, % sevenZExtractPath . "\" . systemName . "\*.*", 2, 0
					sevenZExtractPathFoldersList = % sevenZExtractPathFoldersList . A_LoopFileTimeCreated . "|" . A_LoopFileLongPath . "`n"
			} else {
				Loop, % sevenZExtractPath . "\*.*", 2, 0
					Loop, % A_LoopFileLongPath . "\*.*", 2, 0
						sevenZExtractPathFoldersList = % sevenZExtractPathFoldersList . A_LoopFileTimeCreated . "|" . A_LoopFileLongPath . "`n"
			}
		} else {
			Loop, % sevenZExtractPath . "\*.*", 2, 0
				sevenZExtractPathFoldersList = % sevenZExtractPathFoldersList . A_LoopFileTimeCreated . "|" . A_LoopFileLongPath . "`n"
		}
		StringTrimRight, sevenZExtractPathFoldersList, sevenZExtractPathFoldersList, 1
		;Sorting temp game folders by creation date
		Sort, sevenZExtractPathFoldersList, N R
		;Deleting temp extracted games, except for the last created files defined on the sevenZGamesToKeep option. 
		Loop, Parse, sevenZExtractPathFoldersList, `n
		{	if (A_LoopField){
				StringSplit, filePath, A_LoopField,| 
				if (a_index > sevenZGamesToKeep){
					FileRemoveDir, % filePath2, 1	
					RLLog.Info("7zCleanUp - Deleted: " . filePath2)
				} else {
					RLLog.Info("7zCleanUp - File Kept: " . filePath2)
				}
			}
		}
		;Deleting residual empty system named folders
		Loop, % sevenZExtractPath . "\*.*", 2, 0
		{	folderEmpty := true
			Loop, % A_LoopFileLongPath . "\*.*", 1, 1
			{	folderEmpty := false
				break
			}
			if (folderEmpty)
				FileRemoveDir, % A_LoopFileLongPath, 1	
		}
	}
}

; fileExtension must contain the dot character
is7zExtension(fileExtension) {
	Global sevenZFormats

	RLLog.Trace(A_ThisFunc . " - Checking if " . fileExtension . " is a 7z extension")
	sevenZExtArray := StringUtils.Split(sevenZFormats,"|")
	is7zExt := ArrayUtils.ArrayContains(sevenZExtArray,fileExtension)
	RLLog.Trace(A_ThisFunc . " - Result is " . is7zExt)

	Return is7zExt
}

; http://www.autohotkey.com/forum/post-509873.html#509873
StdoutToVar_CreateProcess(sCmd, bStream := False, sDir := "", sInput := "")
{
	DllCall("CreatePipe", "UintP", hStdInRd , "UintP", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)
	VarSetCapacity(pi, 16, 0)
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	NumPut(0x100	, si, 44)		; STARTF_USESTDHANDLES
	NumPut(hStdInRd	, si, 56)		; hStdInput
	NumPut(hStdOutWr, si, 60)		; hStdOutput
	NumPut(hStdOutWr, si, 64)		; hStdError
	If Not	DllCall("CreateProcess", "Uint", 0, "Uint", &sCmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", sDir ? &sDir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		ExitApp
	DllCall("CloseHandle", "Uint", NumGet(pi,0))
	DllCall("CloseHandle", "Uint", NumGet(pi,4))
	DllCall("CloseHandle", "Uint", hStdOutWr)
	DllCall("CloseHandle", "Uint", hStdInRd)
	If	sInput <>
	DllCall("WriteFile", "Uint", hStdInWr, "Uint", &sInput, "Uint", StrLen(sInput), "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hStdInWr)
	bStream ? (bAlloc:=DllCall("AllocConsole"),hCon:=DllCall("CreateFile","str","CON","Uint",0x40000000,"Uint",bAlloc ? 0 : 3,"Uint",0,"Uint",3,"Uint",0,"Uint",0)) : ""
	VarSetCapacity(sTemp, nTemp:=bStream ? 64-nTrim:=1 : 4095)
	Loop
		If	DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0)&&nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1), sOutput.=sTemp
			If	bStream&&hCon+1
				Loop
					If	RegExMatch(sOutput, "[^\n]*\n", sTrim, nTrim)
						DllCall("WriteFile", "Uint", hCon, "Uint", &sTrim, "Uint", StrLen(sTrim), "UintP", nSize:=0, "Uint", 0)&&nSize ? nTrim+=nSize : ""
					Else	Break
		}
		Else	Break
	DllCall("CloseHandle", "Uint", hStdOutRd)
	bStream ? (DllCall("Sleep","Uint",1000),hCon+1 ? DllCall("CloseHandle","Uint",hCon) : "",bAlloc ? DllCall("FreeConsole") : "") : ""
	Return	sOutput
}

; CheckForRomExt() {
	; Global romExtensions,sevenZFormatsNoP,skipChecks,RLLog
	; If !RegExMatch(skipChecks,"i)Rom Only|Rom and Emu")
	; {	RLLog.Info("CheckForRomExt - Started")
		; Loop, Parse, romExtensions, |
		; {	If A_LoopField in %sevenZFormatsNoP%
			; {	notFound = 1
				; Continue
			; } Else {
				; RLLog.Info("CheckForRomExt - Ended - Rom extensions found in " . romExtensions)
				; Return
			; }
		; }
		; If notFound = 1
			; ScriptError("You did not supply any valid rom extensions to search for in your compressed roms. Please turn off 7z support or add at least one rom extension to Rom_Extension: " . romExtensions)
	; }
; }
