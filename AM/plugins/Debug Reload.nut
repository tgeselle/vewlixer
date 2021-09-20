// Layout User Options
class UserConfig </ help="A plugin that helps to debug layouts." /> {
	</ label="Reload Layout Key",
		help="The key that triggers the layout to reload.",
		options="Custom1, Custom2, Custom3, Custom4, Custom5, Custom6",
		order=1 />
	reloadKey="Custom1";
}

// Debug
class Debug {
	config = null;
	reloadKey = "";
	
	constructor() {
		config = fe.get_config();
		reloadKey = config["reloadKey"].tolower();
		
		fe.add_signal_handler(this, "reload");
	}
	
	// Reload Layout on Key Press
	function reload(str) {
		if (str == reloadKey) fe.signal("reload");
		return false;
	}
}
fe.plugin["Debug"] <- Debug();