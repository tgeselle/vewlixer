// Log messages
class Log {
	prefix="";
	suffix="";
	
	constructor(p=" - Debug message: ", s="\n") {
		prefix = p;
		suffix = s;
	}
	
	function send(obj) {
		print(prefix + obj + suffix);
	}
}
