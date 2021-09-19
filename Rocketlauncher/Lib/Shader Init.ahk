MCRC := "7BA0B77F"
MVersion := "1.0.2"

;Loading shader json config
If FileExist(RLMediaPath . "\Shaders\" . shaderName . "\" . shaderName . ".json"){
	shaderObj := {}
	shaderObj := JSON_load(RLMediaPath . "\Shaders\" . shaderName . "\" . shaderName . ".json")	
	RLLog.Info("Shader Init - Loading shader configuration found at: " . RLMediaPath . "\Shaders\" . shaderName . "\" . shaderName . ".json")
}
