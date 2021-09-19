MCRC := "7FA676AD"
MVersion := "1.0.1"

; Inherited class for File
; Instantiated by creating the inifile instance first:
; iniFile := new IniFile(pathToIni)
; iniVar1 := iniFile.IniRead(section1,key1,default1)
class IniFile extends File
{
	;vars
	; no unique vars, all inherited from File class

	__New(fullFilePath)
	{
		base.__New(fullFilePath)	; extends to use super class constructor so all File methods can be used directly, (ex FileFullPath, FileName, FilePath, etc)
		RLLog.Trace(A_ThisFunc . " - Created new ini object of: """ . this.FileFullPath . """")
	}
	
	; Replaces standard ahk IniRead calls
	; Will not let ERROR be returned, returns no value instead
	; If errormsg is set, will trigger ScriptError instead of returning no or default value
	Read(section,key,defaultvalue:="",errorMsg:="")
	{
		RLLog.Debug(A_ThisFunc . " - SECTION: [" . section . "] - KEY: " . key . " - VALUE: " . value . " - FILE: " . this.FileFullPath)
		IniRead, v, % this.FileFullPath, %section%, %key%, %defaultvalue%
		If (v = "ERROR" || v = A_Space) {	; if key does not exist or is a space, delete ERROR as the value
			If errorMsg
				ScriptError(errorMsg)
			Else {
				If defaultValue = %A_Space%	; this prevents the var from existing when it's actually blank
					defaultValue := ""
				Return defaultValue
			}
		}
		Return v
	}

	; Replaces standard ahk IniWrite calls
	; compare = if used, only writes new value if existing value differs
	Write(value,section,key,compare:="")
	{
		If compare {
			IniRead, v, % this.FileFullPath, %section%, %key%
			If (v != value) {
				IniWrite, %value%, % this.FileFullPath, %section%, %key%
				err := ErrorLevel
				RLLog.Info(A_ThisFunc . " - ini updated due to differed value. SECTION: [" . section . "] - KEY: " . key . " - Old: " . v . " | New: " . value)
			} Else
				RLLog.Debug(A_ThisFunc . " - ini value already correct. SECTION: [" . section . "] - KEY: " . key . " - Value: " . value)
		} Else {
			IniWrite, %value%, % this.FileFullPath, %section%, %key%
			err := ErrorLevel
			RLLog.Info(A_ThisFunc . " - SECTION: [" . section . "] - KEY: " . key . " - VALUE: " . value . " - FILE: " . this.FileFullPath)
		}
		If err {
			attribValues := {R: "READONLY",A: "ARCHIVE",S: "SYSTEM",H: "HIDDEN",N: "NORMAL",D: "DIRECTORY",O: "OFFLINE",C: "COMPRESSED",T: "TEMPORARY"}
			attribs := this.FileGetAttrib(this.FileFullPath,0)
			RLLog.Warning(A_ThisFunc . " - There was an error writing to this ini." . (attribs ? " It has " . attribs . " attributes set" : ""))
		}
		Return err	; returns 1 if there was an error
	}

	; Mainly used in modules to read module.ini settings so multiple sections of an ini can be read of the same key name
	; section: Allows | separated values so multiple sections can be checked.
	ReadCheck(section,key,defaultvalue:="",errorMsg:="",logType:="") {
		Loop, Parse, section, |
		{	section%A_Index% := A_LoopField	; keep each parsed section in its own var
			If iniVar != ""	; if last loop's iniVar has a value, update this loop's default value with it
				defaultValue := If A_Index = 1 ? defaultValue : iniVar	; on first loop, default value will be the one sent to the function, on following loops it gets the value from the previous loop
			IniRead, iniVar, % this.FileFullPath, % section%A_Index%, %key%, %defaultvalue%
			If (IniVar = "ERROR" || iniVar = A_Space)	; if key does not exist or is a space, delete ERROR as the value
				iniVar := ""
			If (A_Index = 1 && iniVar = ""  and !logType) {
				If errorMsg
					ScriptError(errorMsg)
				Else
					IniWrite, %defaultValue%, % this.FileFullPath, % section%A_Index%, %key%
				Return defaultValue
			}
			If logType	; only log if logType set
			{	logAr := ["Module","Bezel"]
				RLLog.Info(logAr[logType] . " Setting - [" . section%A_Index% . "] - " . key . ": " . iniVar)
			}
			If (iniVar != "")	; if IniVar contains a value, update the lastIniVar
				lastIniVar := iniVar
		}
		If defaultValue = %A_Space%	; this prevents the var from existing when it's actually blank
			defaultValue := ""
		Return If A_Index = 1 ? iniVar : If lastIniVar != "" ? lastIniVar : defaultValue	; if this is the first loop, always return the iniVar. If any other loop, return the lastinivar if it was filled, otherwise send the last updated defaultvalue
	}
}
