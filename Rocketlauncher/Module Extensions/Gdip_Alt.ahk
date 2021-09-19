MCRC := "50C750BF"
MVersion := "1.0.3"

;Alternative Gdip function wrappers with support for graphics rotation

Alt_UpdateLayeredWindow(hwnd, hdc,X:="", Y:="",W:="",H:="",Alpha:=255,monitorLeft:=0,monitorTop:=0,rotationAngle:="",xTransl:="",yTransl:=""){
	Global screenRotationAngle, xTranslation, yTranslation
	rotationAngle := (rotationAngle="") ? screenRotationAngle : rotationAngle
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	if rotationAngle
		WindowCoordUpdate(X,Y,W,H,rotationAngle,xTransl,yTransl)
Return UpdateLayeredWindow(hwnd, hdc, X+monitorLeft, Y+monitorTop, W, H, Alpha)	
}

Gdip_Alt_TextToGraphics(pGraphics, Text, Options, Font:="Arial", Width:="", Height:="", Measure:=0,xTransl:="",yTransl:="",baseWidth:="",baseHeight:=""){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	baseWidth := (baseWidth="") ? baseScreenWidth : baseWidth
	baseHeight := (baseHeight="") ? baseScreenHeight : baseHeight
	RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
	X := SubStr(xpos, 2), Y := SubStr(ypos, 2)
	GraphicsCoordUpdate(pGraphics,X,Y,xTransl,yTransl,baseWidth,baseHeight)
	Options := RegExReplace(Options, "i)X([\-\d\.]+)(p*)", "x" . X)
	Options := RegExReplace(Options, "i)Y([\-\d\.]+)(p*)", "y" . Y)
Return Gdip_TextToGraphics(pGraphics, Text, Options, Font, Width, Height, Measure)
}

Gdip_Alt_DrawRectangle(pGraphics, pPen, x, y, w, h,xTransl:="",yTransl:="",baseWidth:="",baseHeight:=""){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	baseWidth := (baseWidth="") ? baseScreenWidth : baseWidth
	baseHeight := (baseHeight="") ? baseScreenHeight : baseHeight
	GraphicsCoordUpdate(pGraphics,x,y,xTransl,yTransl,baseWidth,baseHeight)
Return Gdip_DrawRectangle(pGraphics, pPen, X, Y, W, H)
}

Gdip_Alt_FillRectangle(pGraphics, pBrush, X, Y, W, H,xTransl:="",yTransl:="",baseWidth:="",baseHeight:=""){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	baseWidth := (baseWidth="") ? baseScreenWidth : baseWidth
	baseHeight := (baseHeight="") ? baseScreenHeight : baseHeight
	GraphicsCoordUpdate(pGraphics,X,Y,xTransl,yTransl,baseWidth,baseHeight)
Return Gdip_FillRectangle(pGraphics, pBrush, X, Y, W, H)
}

Gdip_Alt_DrawImage(pGraphics, pBitmap, dx:="", dy:="", dw:="", dh:="", sx:="", sy:="", sw:="", sh:="", Matrix:=1,xTransl:="",yTransl:="",baseWidth:="",baseHeight:=""){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	baseWidth := (baseWidth="") ? baseScreenWidth : baseWidth
	baseHeight := (baseHeight="") ? baseScreenHeight : baseHeight
	GraphicsCoordUpdate(pGraphics,dx,dy,xTransl,yTransl,baseWidth,baseHeight)
Return Gdip_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)
}

Gdip_Alt_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r,xTransl:="",yTransl:="",baseWidth:="",baseHeight:=""){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	baseWidth := (baseWidth="") ? baseScreenWidth : baseWidth
	baseHeight := (baseHeight="") ? baseScreenHeight : baseHeight
	GraphicsCoordUpdate(pGraphics,X,Y,xTransl,yTransl,baseWidth,baseHeight)
Return Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
}

Gdip_Alt_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r,xTransl:="",yTransl:="",baseWidth:="",baseHeight:=""){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	baseWidth := (baseWidth="") ? baseScreenWidth : baseWidth
	baseHeight := (baseHeight="") ? baseScreenHeight : baseHeight
	GraphicsCoordUpdate(pGraphics,X,Y,xTransl,yTransl,baseWidth,baseHeight)
Return Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
}

Gdip_Alt_GetRotatedDimensions(Width, Height, Angle, ByRef RWidth, ByRef RHeight)
{
	pi := 3.14159, TAngle := Angle*(pi/180)
	RWidth := Round(Abs(Width*Cos(TAngle))+Abs(Height*Sin(TAngle)))
	RHeight := Round(Abs(Width*Sin(TAngle))+Abs(Height*Cos(Tangle)))
}

WindowCoordUpdate(ByRef X, ByRef Y, ByRef W, ByRef H,rotationAngle:="",xTransl:="",yTransl:=""){
	global xTranslation, yTranslation, screenRotationAngle
	rotationAngle := (rotationAngle="") ? screenRotationAngle : rotationAngle
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	Gdip_Alt_GetRotatedDimensions(W, H, rotationAngle, rW, rH)
	W := rW, H := rH 
	Gdip_Alt_GetRotatedDimensions(X, Y, rotationAngle, rotX, rotY)
	X := if xTransl ? xTransl - rotX - W : rotX	
	Y := if yTransl ? yTransl - rotY - H : rotY		
}

GraphicsCoordUpdate(pGraphics,ByRef x,ByRef y,xTransl:="",yTransl:="",baseWidth:="",baseHeight:=""){
	global xTranslation, yTranslation, baseScreenWidth, baseScreenHeight, pGraphicsUpd
	xTransl := (xTransl="") ? xTranslation : xTransl
	yTransl := (yTransl="") ? yTranslation : yTransl
	baseWidth := (baseWidth="") ? baseScreenWidth : baseWidth
	baseHeight := (baseHeight="") ? baseScreenHeight : baseHeight
	x := if (yTransl) ? (baseWidth - pGraphicsUpd[pGraphics,"W"] + x) : x	
	y := if (xTransl) ? (baseHeight - pGraphicsUpd[pGraphics,"H"] + y) : y
}


pGraphUpd(pGraphics,W,H){
	Global pGraphicsUpd
	if !pGraphicsUpd
		pGraphicsUpd := []
	pGraphicsUpd[pGraphics,"W"]:=W
	pGraphicsUpd[pGraphics,"H"]:=H
}