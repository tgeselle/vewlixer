MCRC := "931DB808"
MVersion := "1.0.4"

pauseKey := xHotKeyVarEdit(pauseKey,"pauseKey","~","Add")
pauseBackToMenuBarKey := xHotKeyVarEdit(pauseBackToMenuBarKey,"pauseBackToMenuBarKey","~","Remove")
pauseZoomInKey := xHotKeyVarEdit(pauseZoomInKey,"pauseZoomInKey","~","Remove")
pauseZoomOutKey := xHotKeyVarEdit(pauseZoomOutKey,"pauseZoomOutKey","~","Remove")
pauseScreenshotKey := xHotKeyVarEdit(pauseScreenshotKey,"pauseScreenshotKey","~","Remove")

XHotKeywrapper(pauseKey,"TogglePauseMenuStatus")
XHotKeywrapper(pauseScreenshotKey,"SaveScreenshot")
