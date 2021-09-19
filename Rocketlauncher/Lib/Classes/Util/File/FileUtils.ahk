MCRC := "A6C63107"
MVersion := "1.0.0"

; Instantiated by creating the FileUtils instance first:
; file := new FileUtils(pathToFile)
class FileUtils
{
	;vars
	
	__New(fullFilePath,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Creating new FileUtils object of: """ . fullFilePath . """")
	}

	__Delete()
	{
	}
}
