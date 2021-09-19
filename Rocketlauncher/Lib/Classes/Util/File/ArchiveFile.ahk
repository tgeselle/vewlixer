MCRC := "DE846D5"
MVersion := "1.0.0"

; Instantiated by creating the ArchiveFile instance first:
; file := new ArchiveFile(pathToFile)
class ArchiveFile
{
	;vars
	
	__New(fullFilePath,log:=1)
	{
		If log
			RLLog.Trace(A_ThisFunc . " - Creating new ArchiveFile object of: """ . fullFilePath . """")
	}

	__Delete()
	{
	}
}
