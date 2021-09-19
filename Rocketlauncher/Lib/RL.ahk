MCRC=BCDA734B
MVersion=1.0

; This library allows access to various supported methods for the RocketLauncher.dll

;--- Startup Function ---

; Required to create the RL dll object before using any of the dll's methods
RL_start(file) {
	try {
		If !FileExist(file)
		{	MsgBox, 16, Error, Missing %file%, 5
			ExitApp
		}
		CLR_Start()
		If !hModule := CLR_LoadLibrary(file)
			ScriptError("Error loading the DLL: " . file)
		If !Object := CLR_CreateObject(hModule,"RocketLauncher.Utils.MainDriver")
			ScriptError("Error creating object. There may be something wrong with the dll file: " . file)
		Return Object
	}
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

initDllObject(ByRef dllObject) {
  Global RLObject

  If (!dllObject)
    dllObject := RLObject
}


;--- Zip Functions ---

; Sets the path to the 7z Library
; public void set7zdllPath(String sevenzdllPath)
RL_set7zdllPath(sevenzdllPath,ByRef dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.set7zdllPath(sevenzdllPath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the first found file inside a supported archive when only supplying an extension. Returns empty string if no matches are found.
; public String findByExtension(String zipfilepath, String extensions)
RL_findByExtension(zipfilepath,extensions,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.findByExtension(zipfilepath,extensions)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the length of the path for deepest file inside the archive. This can be used to check if extracting an archive won't break the 255 character limit that exists in Windows.
; public int getLongestPathSize(String zipfilepath)
RL_getLongestPathSize(zipfilepath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getLongestPathSize(zipfilepath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the number of files inside the archive (folders are not considered).
; public int getZipFileCount(String zipfilepath)
RL_getZipFileCount(zipfilepath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getZipFileCount(zipfilepath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns a | separated string of all files inside a supported archive. Also returns the compression method for each file. Output format is "filename 1|compression type/filename 2|compression type/..." This can be useful for example to debug situations while the progress bar stays at 0% for a while due to the compression method used
; public String getZipFileList(String zipfilepath)
RL_getZipFileList(zipfilepath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getZipFileList(zipfilepath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Check if compressed files contain illegal filename characters which wouldn't allow it to be uncompressed under Windows. This is needed for the WinUAE module for example as some invalid Windows characters are actually valid AmigaDOS filenames. Returns 1 - Has invalid chars; 0 - No invalid chars
; public int checkInvalidCharacters(String zipfilepath)
RL_checkInvalidCharacters(zipfilepath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.checkInvalidCharacters(zipfilepath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Searches for a specific file inside a supported archive. The first file matching the conditions will be returned. Returns empty string if no matches are found
; public String findFileInZip(String zipfilepath, String filenames, String extensions)
RL_findFileInZip(zipfilepath,filenames,extensions,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.findFileInZip(zipfilepath,filenames,extensions)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the uncompressed size in bytes, or size on disk, of all files an archive will use when extracted.
; public ulong getZipExtractedSize(String zipfilepath)
RL_getZipExtractedSize(zipfilepath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getZipExtractedSize(zipfilepath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns a | separated string of the current file being extracted and a percentage for the global extraction. Used as a method to determine extraction progress. Only use the Fast Extraction Mode (mode=1) when you are expecting a folder with hundreds of small files inside it otherwise always use the Accurate one (mode=0).
; public String getExtractionProgress(String extractionPath, long totalSize, int mode)
RL_getExtractionProgress(extractionPath,totalSize,mode,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getExtractionProgress(extractionPath,totalSize,mode)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns a | separated string of the current file being extracted and current size on disk. Used as a method to determine extraction progress. Only use the Fast Extraction Mode (mode=1) when you are expecting a folder with hundreds of small files inside it otherwise always use the Accurate one (mode=0).
; public String getExtractionSize(String path, int mode)
RL_getExtractionSize(path,mode,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getExtractionSize(path,mode)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the size in bytes of the specified folder and all it's contents including sub-folders. Only use the Fast Extraction Mode (mode=1) when you are expecting a folder with hundreds of small files inside it otherwise always use the Accurate one (mode=0).
; public long getFolderSize(String path, int mode)
RL_getFolderSize(path,mode,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getFolderSize(path,mode)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Detects if the specified archive contains a unique folder as the archive root. It will return an empty String if there are multiple folders in the archive root or if any file is found in the archive root
; public String getZipRootFolder(String zipfilepath)
RL_getZipRootFolder(zipfilepath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getZipRootFolder(zipfilepath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- PDF Functions ---

; Converts a PDF file to several PNG files (one per page). firstPage and lastPage are optional and if not provided it will convert the whole PDF file. PNG files will be generated to outputPath and will be named pageX.png where X is the page number.
; public void generatePngFromPdf(String inputPath, String outputPath, int dpiResolution, int maximumHeight = 0, int firstPage = 1, int lastPage = 0, String pageLayout = null)
RL_generatePngFromPdf(inputPath,outputPath,dpiResolution,maximumHeight=0,firstPage=1,lastPage=0,pageLayout="null",dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.generatePngFromPdf(inputPath,outputPath,dpiResolution,maximumHeight,firstPage,lastPage,pageLayout)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the number of pages of a PDF file
; public int getPdfPageCount(String inputPath, String pageLayout = null)
RL_getPdfPageCount(inputPath,pageLayout="null",dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getPdfPageCount(inputPath,pageLayout)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Controller Functions ---

; Returns a binary string with 16 characters representing the 16 possible joystick ports windows supports. Example 1100000000000000. A 1 represents a joystick is in that port, 0 means no joystick. You read the binary from left to right with left most number being port 0 and right most port being port 15 (16 ports in total).
; public String getConnectedJoysticks()
RL_getConnectedJoysticks(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getConnectedJoysticks()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Module Functions ---

; Checks if a Module CRC matches the one in the module header can also test Library or Extensions
; For Module CRC Checking use: checkModuleCRC(PATH_TO_AHK_FILE, "", true)
; For Ahk Library CRC Checking (CLR,Gdip,etc.) use: checkModuleCRC(PATH_TO_AHK_FILE, CRC_VALUE, false)
; For RocketLauncher Extensions Checking (Pause,FadeAnimations,etc.) use: checkModuleCRC(PATH_TO_AHK_FILE, "", false)
; Returns: -1 - Module file not found; 0 - CRC doesn't match; 1 - CRC matches; 2 - Module has no CRC defined on the header
; public int checkModuleCRC(string fileName, string crc, bool isModule)
RL_checkModuleCRC(fileName,crc,isModule,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.checkModuleCRC(fileName,crc,isModule)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Rom Functions ---

; Validates if the contents of a CUE file is valid, namely if all files referenced by it exist. Returns 0-If CUE is invalid, 1-If CUE is valid, 2-If CUE cannot be found.
; public int validateCUE(String cueFilePath)
RL_validateCUE(cueFilePath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.validateCUE(cueFilePath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

;  Validates if GDI file is valid, namely if all files referenced by it exist. Returns 0-If GDI is invalid, 1-If GDI is valid, 2-If GDI cannot be found, 3-If Invalid Double Quotes were found.
; public int validateGDI(String gdiFilePath, bool acceptDoubleQuotes)
RL_validateGDI(gdiFilePath,acceptDoubleQuotes,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.validateGDI(gdiFilePath,acceptDoubleQuotes)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Searches CUE file for tracks with the specified file extensions. Useful to determine if mp3 files are being referenced by the CUE file for example since Daemon Tools Lite won't support them. Returns 0-Not found, 1-Found, 2-CUE file cannot be found, 3-CUE is invalid.
; public int findCUETracksByExtension(String cueFilePath, String file_extensions)
RL_findCUETracksByExtension(cueFilePath,file_extensions,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.findCUETracksByExtension(cueFilePath,file_extensions)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Lists all files referenced by the provided CUE file split with the | character. The CUE file won't be validated so make sure you call validateCUE before calling this method if you want to be sure the file is valid. cueIndex=0 will list all entries, cueIndex=1 will list only the first entry and so on.
; public String listCUEFiles(String cueFilePath, int cueIndex = 0)
RL_listCUEFiles(cueFilePath,cueIndex=0,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.listCUEFiles(cueFilePath,cueIndex)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- File Functions ---

; Reads file contents with a certain length and starting with a specified offset. Return data read, if an invalid mode is specified will return ERROR.
; public String readFileData(String filePath, int startOffset, int bytesToRead, String mode)
RL_readFileData(filePath,startOffset,bytesToRead,mode,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.readFileData(filePath,startOffset,bytesToRead,mode)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Gets the File Encoding from a file based on the byte order mark (BOM) character in a text file if one exists. If the BOM character isn't set or not recognized it will return an empty string.
; public String getFileEncoding(String filePath)
RL_getFileEncoding(filePath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getFileEncoding(filePath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Removes BOM character from a text file if it exists. Returns 1-If BOM character was removed; 0-If there was nothing to remove.
; public int removeBOM(String filePath)
RL_removeBOM(filePath,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.removeBOM(filePath)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Service Functions ---

; Returns status of the service. Returns -1 if status could not be determined; 0 if not running; 1 if running.
; public int getServiceStatus(String serviceName)
RL_getServiceStatus(serviceName,ByRef dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getServiceStatus(serviceName)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Display Functions ---

; Checks if it's possible to change the display settings to the desired values. Returns 1 is it's possible, error message otherwise.
; public String checkDisplaySettings(String displayName, uint width, uint height, uint bitDepth, uint frequency)
RL_checkDisplaySettings(displayName,width,height,bitDepth,frequency,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.checkDisplaySettings(displayName,width,height,bitDepth,frequency)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Changes display settings to the specified values. Returns 1 if change succeeded, error message otherwise.
; public String changeDisplaySettings(String displayName, uint width, uint height, uint bitDepth, uint frequency)
RL_changeDisplaySettings(displayName,width,height,bitDepth,frequency,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.changeDisplaySettings(displayName,width,height,bitDepth,frequency)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns display settings for the specified monitor in format: width|height|bits|frequency|orientation
; public String getDisplaySettings(String displayName)
RL_getDisplaySettings(displayName,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getDisplaySettings(displayName)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Windows Functions ---

; Returns the language in which the Windows UI is displayed right now. This might be different from the windows install UI if there's a MUI or LIP installed.
; public String getWindowsUILanguage()
RL_getWindowsUILanguage(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getWindowsUILanguage()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the Locale specified for formats. This should be exposed by Control Panel >> Region and Language >> Formats
; public String getFormatsLocale()
RL_getFormatsLocale(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getFormatsLocale()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the encoding for the operating system's current ANSI code page.
; public String getTextEncoding()
RL_getTextEncoding(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getTextEncoding()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns the current system locale. This controls the language used when displaying text in programs that do not support Unicode. Should be exposed by ControlPanel >> Region and Language >> Administrative >> Change System Locale.
; public String getSystemLocale()
RL_getSystemLocale(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.getSystemLocale()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Log Functions ---

; Sets current Log Mode. newlogMode can be one of: 0-Disabled; 1-Log to File (RocketLauncher.DLL.log); 2-Log to Memory (use readLogData() to retrieve log entries).
; public void setLogMode(String newlogMode, int newFile, String logThread)
RL_setLogMode(newlogMode,newFile,logThread,ByRef dllObject="") {
    initDllObject(dllObject)

    try
        Return dllObject.setLogMode(newlogMode,newFile,logThread)
    catch
        ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Redirects log to a different file other than the default one. Default name is RocketLauncher.DLL.log
; public void setLogFilename(String filename)
RL_setLogFilename(filename,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.setLogFilename(filename)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Returns all log entries from memory
; public String readLogData()
RL_readLogData(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.readLogData()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Writes all log entries from memory to the log file
; public void writeLogData()
RL_writeLogData(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.writeLogData()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Security Functions ---

; Verifies if the specified password is valid
; public int VerifyPassword(String plainValue, String hashedValue)
RL_VerifyPassword(plainValue,hashedValue,dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.VerifyPassword(plainValue,hashedValue)
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}


;--- Test Functions ---

; Testing purposes, returns "OK"
; public String test()
RL_test(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.test()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}

; Testing purposes, always throw an Exception
; public String testException()
RL_testException(dllObject="") {
    initDllObject(dllObject)

	try
		Return dllObject.testException()
	catch
		ScriptError(A_ThisFunc . " - Exception thrown:`n" e.message)
}
