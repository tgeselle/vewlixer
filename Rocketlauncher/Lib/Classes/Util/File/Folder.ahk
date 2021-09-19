MCRC := "34F0E45F"
MVersion := "1.0.1"

; Instantiated by creating the folder instance first:
; folder := new Folder(FolderPath)
class Folder extends File
{
	;vars
	; inherits all vars from File class

	__New(FolderPath,log:=1)
	{
		base.__New(FolderPath)	; extends to use super class constructor so all File methods can be used directly, (ex FileFullPath, FilePath, etc)
		this.FilePath := this.FileFullPath
		; these are empty on folders
		this.FileName := ""
		this.FileNameNoExt := ""
		this.FileExt := ""
		If log
			RLLog.Trace(A_ThisFunc . " - Created new folder object of: """ . this.FileFullPath . """")
	}
}
