MCRC := "1E56393C"
MVersion := "1.0.4"

If fadeInterruptKey != anykey
	fadeInterruptKey := xHotKeyVarEdit(fadeInterruptKey,"fadeInterruptKey","~","Remove")
Else
	InterruptMouseButtons := ["LButton","MButton","RButton"]

fadeAnimationsIni := libPath . "\Fade Animations.ini"
IfNotExist, %fadeAnimationsIni%
FileAppend,,%fadeAnimationsIni%

FileRead, fadeAnimFile, %libPath%\Fade Animations.ahk
IfNotInString, fadeAnimFile, %fadeInTransitionAnimation%(
	fadeInTransitionAnimation := "DefaultAnimateFadeIn"
IfNotInString, fadeAnimFile, %fadeOutTransitionAnimation%(
	fadeOutTransitionAnimation := "DefaultAnimateFadeOut"
IfNotInString, fadeAnimFile, %fadeLyr3Animation%:
	fadeLyr3Animation := "DefaultFadeAnimation"
IfNotInString,  fadeAnimFile, %fadeLyr37zAnimation%:
	fadeLyr37zAnimation := "DefaultFadeAnimation"
Log("fadeInTransitionAnimation: " . fadeInTransitionAnimation,4)
Log("fadeOutTransitionAnimation: " . fadeOutTransitionAnimation,4)
Log("fadeLyr3Animation: " . fadeLyr3Animation,4)
Log("fadeLyr37zAnimation: " . fadeLyr37zAnimation,4)

fadeClickThrough := (fadeClickThrough ="true") ? "+E0x20" : ""

