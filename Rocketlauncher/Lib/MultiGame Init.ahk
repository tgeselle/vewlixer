MCRC := "D50F0E70"
MVersion := "1.0.1"

SetBatchLines, -1
mgKey := xHotKeyVarEdit(mgKey,"mgKey","~","Add")
xHotKeywrapper(mgKey,"StartMulti")	; Add MultiGame hotkey