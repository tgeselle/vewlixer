MCRC := "788DAD79"
MVersion := "1.6.4"

; Instantiated by creating the file instance first:
; file := new File(pathToFile)
; errLvl := file.Delete()
class File
{
	;vars
	; Attributes
	; FileDrive
	; FileFullPath
	; FileName
	; FileNameNoExt
	; FilePath
	; FileExt
	
	;if Read() is called
	; OriginalText	; this is unaltered text from initial Read()
	; Text			; If any changes are to be made, they should be made on this var

	__New(fullFilePath,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Creating new file object of: """ . fullFilePath . """")
		If !fullFilePath
			ScriptError(A_ThisFunc . " - fullFilePath parameter cannot be blank to instantiate this class.")
		If StringUtils.IsRelative(fullFilePath,0)
			fullFilePath := RLObject.getFullPathFromRelative(rlPath,fullFilePath)
		StringUtils.SplitPath(fullFilePath, n, p, e, ne, d)
		this.FileDrive := d
		this.FileFullPath := fullFilePath
		this.FileName := n
		this.FileNameNoExt := ne
		this.FilePath := p
		this.FileExt := e
	}

	__Delete()
	{
		this.FileDrive := ""
		this.FileFullPath := ""
		this.FileName := ""
		this.FileNameNoExt := ""
		this.FilePath := ""
		this.FileExt := ""
	}

	Append(text:="",encoding:="",log:=1)
	{
		If !encoding
			encoding := A_FileEncoding	; set encoding to current global setting
		If log
			RLLog.Trace(A_ThisFunc . " - Appending " . this.FileName . " with: """ . text . """")
		FileAppend, % text, % this.FileFullPath, % encoding
		Return ErrorLevel
	}

	; CheckFile Usage:
	; file = file to be checked if it exists
	; msg = the error msg you want displayed on screen if you don't want the default "file not found"
	; timeout = gets passed to ScriptError(), the amount of time you want the error to show on screen
	; crc = If this is a an AHK library only, provide a crc so it can be validated
	; crctype = default empty and crc is not checked. Use 0 for AHK libraries and RocketLauncher extension files. Use 1 for module crc checks..
	; logerror = default empty will give a log error instead of stopping with a scripterror
	; allowFolder = allows folders or files w/o an extension to be checked. By default a file must have an extension.
	CheckFile(msg:="",timeout:=6,crc:="",crctype:="",logerror:="",allowFolder:=0){
		Global logIncludeFileProperties
		exeFileInfo := "
		( LTrim
		FileDescription
		FileVersion
		InternalName
		LegalCopyright
		OriginalFilename
		ProductName
		ProductVersion
		CompanyName
		PrivateBuild
		SpecialBuild
		LegalTrademarks
		)"

		RLLog.Info(A_ThisFunc . " - Checking if """ . this.FileFullPath . """ exists")
		If !this.Exist() {
			exampleFile := new File(this.FilePath . "\" . this.FileNameNoExt . " (Example)." . this.FileExt)
			If exampleFile.Exist() {
				errLvl := exampleFile.Copy(this.FileFullPath)
				If errLvl
					RLLog.Error(A_ThisFunc . " - Found an example for this file, but did not have permissions to restore it: """ . exampleFile.FileFullPath . """")
				Else
					RLLog.Warning(A_ThisFunc . " - Restored this file from its example: """ . exampleFile.FileFullPath . """")
			} Else {
				If (msg != "")
					ScriptError(msg, timeout)
				Else
					ScriptError("Cannot find " . this.FileFullPath, timeout)
			}
		}
		If (!this.fileExt && !allowFolder)
			ScriptError("This is a folder and must point to a file instead: " . this.FileFullPath, timeout)

		If (crctype = 0 Or crctype = 1) {
			CRCResult := RLObject.checkModuleCRC("" . this.FileFullPath . "",crc,crctype)
			If (CRCResult = -1)
				RLLog.Error("CRC Check - " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Library" : "Extension") . " file not found: " . this.FileFullPath)
			Else If (CRCResult = 0)
				If (crctype = 1)
					RLLog.Warning("CRC Check - CRC does not match official module and will not be supported. Continue using at your own risk: " . this.FileFullPath)
				Else If logerror
					RLLog.Error("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Library" : "Extension") . ". Please re-download this file to continue using RocketLauncher: " . this.FileFullPath)
				Else
					ScriptError("CRC Check - CRC does not match for this " . (If (crctype=0 && crc) ? "Library" : "Extension") . ". Please re-download this file to continue using RocketLauncher: " . this.FileFullPath)
			Else If (CRCResult = 1)
				RLLog.Debug("CRC Check - CRC matches, this is an official unedited " . (If crctype=1 ? "Module" : If (crctype=0 && crc) ? "Library" : "Extension") . ": " . this.FileFullPath)
			Else If (CRCResult = 2)
				RLLog.Error("CRC Check - No CRC defined on the header for: " . this.FileFullPath)
		}

		If (logIncludeFileProperties = "true")
		{	If exeAtrib := this.GetVersionInfo_AW(exeFileInfo, "`n")
				Loop, Parse, exeAtrib, `n
					logTxt .= (If A_Index=1 ? "":"`n") . "`t`t`t`t`t" . A_LoopField
			FileGetSize, fileSize, % this.FileFullPath
			FileGetTime, fileTimeC, % this.FileFullPath, C
			FormatTime, fileTimeC, %fileTimeC%, M/d/yyyy - h:mm:ss tt
			FileGetTime, fileTimeM, % this.FileFullPath, M
			FormatTime, fileTimeM, %fileTimeM%, M/d/yyyy - h:mm:ss tt
			logTxt .= (If logTxt ? "`r`n":"") . "`t`t`t`t`tFile Size:`t`t`t" . fileSize . " bytes"
			logTxt .= "`r`n`t`t`t`t`tCreated:`t`t`t" . fileTimeC
			logTxt .= "`r`n`t`t`t`t`tModified:`t`t`t" . fileTimeM
			RLLog.Debug(A_ThisFunc . " - Attributes:`r`n" . logTxt)
		}
		Return this.FileFullPath
	}

	CheckFolder(msg:="",timeout:=6,crc:="",crctype:="",logerror:="") {
	   Return this.CheckFile(msg,timeout,crc,crctype,logerror,1)
	}

	Copy(dest:="",flag:=0,sourceWildcard:="",log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Copying from: """ . this.FileFullPath . """ to """ . dest . """")
		FileCopy, % this.FileFullPath . sourceWildcard, % dest, % flag
		Return ErrorLevel
	}

	CreateDir(log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Creating: " . this.FilePath)
		FileCreateDir % this.FilePath
		Return ErrorLevel
	}

	Delete(log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Deleting: " . this.FileName)
		FileDelete % this.FileFullPath
		Return ErrorLevel
	}

	; If check if set, will check for existance of the folder instead of the file if this object contains a file
	Exist(check:="",log:=1)
	{
		If (check != "")
			existCheck := FileExist(this.FilePath)
		Else
			existCheck := FileExist(this.FileFullPath)
		If (log && existCheck) {
			If (check != "")
				RLLog.Trace(A_ThisFunc . " - " . (existCheck ? "This folder exists" : "Does not exist") . ": " . this.FilePath)
			Else
				RLLog.Trace(A_ThisFunc . " - " . (existCheck ? "This file exists" : "Does not exist") . ": " . this.FileFullPath)
		}
		Return existCheck
	}

	GetAttrib(log:=1)
	{
		attribValues := {R: "READONLY",A: "ARCHIVE",S: "SYSTEM",H: "HIDDEN",N: "NORMAL",D: "DIRECTORY",O: "OFFLINE",C: "COMPRESSED",T: "TEMPORARY"}
		FileGetAttrib, fileAttribs, % this.FileFullPath
		If ErrorLevel {
			RLLog.Warning(A_ThisFunc . " - There was an error retrieving attributes for " . this.FileFullPath)
			Return
		}
		attribs := StringUtils.Split(fileAttribs,"","",0)
		v := ""
		Loop % attribs.MaxIndex()
			v .= (A_Index > 1 ? "|" : "") . attribValues[attribs[A_Index]]
		If log
			RLLog.Debug(A_ThisFunc . " - Retrieved attributes: " . v . " for " . this.FileFullPath)
		Return this.Attributes := v
	}
	
	GetSize(Units,log:=1)
	{
		FileGetSize, fsize, % this.FileFullPath, % Units
		If (log)
			RLLog.Trace(A_ThisFunc . " - File Size for " . this.FileFullPath . " is " . fsize . " " . Units)
		Return fsize
	}

	GetVersion(log:=1)
	{
		; version := FileGetVersion(this.FileFullPath)
		FileGetVersion, version, % this.FileFullPath
		If (log)
			RLLog.Trace(A_ThisFunc . " - File version for " . this.FileFullPath . " is " . version)
		Return version
	}

	GetVersionInfo_AW(StringFileInfo:="", Delimiter:="|")
	{
		Static CS, HexVal, Sps:="                        ", DLL:="Version\"
		If ( CS = "" )
			CS := A_IsUnicode ? "W" : "A", HexVal := "msvcrt\s" (A_IsUnicode ? "w": "" ) "printf"
		If ! FSz := DllCall( DLL "GetFileVersionInfoSize" CS , Str,this.FileFullPath, UInt,0 )
			Return "", DllCall( "SetLastError", UInt,1 )
		VarSetCapacity( FVI, FSz, 0 ), VarSetCapacity( Trans,8 * ( A_IsUnicode ? 2 : 1 ) )
		DllCall( DLL "GetFileVersionInfo" CS, Str,this.FileFullPath, Int,0, UInt,FSz, UInt,&FVI )
		If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,"\VarFileInfo\Translation", UIntP,Translation, UInt,0 )
			Return "", DllCall( "SetLastError", UInt,2 )
		eightx := "%08X"
		If ! DllCall( HexVal, Str,Trans, Str, eightx, UInt,NumGet(Translation+0) )
			Return "", DllCall( "SetLastError", UInt,3 )
		Loop, Parse, StringFileInfo, %Delimiter%
		{ subBlock := "\StringFileInfo\" SubStr(Trans,-3) SubStr(Trans,1,4) "\" A_LoopField
			If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,SubBlock, UIntP,InfoPtr, UInt,0 )
				Continue
			Value := DllCall( "MulDiv", UInt,InfoPtr, Int,1, Int,1, "Str"  )
			Info  .= Value ? ( ( InStr( StringFileInfo,Delimiter ) ? SubStr( A_LoopField Sps,1,24 ) . A_Tab : "" ) . Value . Delimiter ) : ""
		} StringTrimRight, Info, Info, 1
		Return Info
	}

	Read(log:=1)
	{
		FileRead, OutputVar, % this.FileFullPath
		errlvl := ErrorLevel
		If !this.OriginalText
			this.OriginalText := OutputVar
		this.Text := OutputVar
		If log
			RLLog.Trace(A_ThisFunc . " - Read file to memory: " . this.FileFullPath)
		Return errlvl
	}
}
