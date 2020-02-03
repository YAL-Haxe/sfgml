package js.lib;

#if sfgml_catch_error
import gml.NativeString;
class Error {
	public var message:String;
	public var name:String = "Error";
	public var stack(default, null):String;

	public function new(?message:String):Void {
		this.message = message;
	}
	
	public function parseGMError(text:String) {
		// trim start:
		var p = NativeString.pos("\r\n\r\n", text);
		if (p > 0) text = NativeString.delete(text, 1, p + 3);
		// grab text:
		var sep = "\r\n at ";
		p = NativeString.pos(sep, text);
		if (p == 0) {
			sep = "\r\n############################################################################################";
			p = NativeString.pos(sep, text);
		}
		if (p == 0) {
			message = text;
			stack = "";
			return;
		} else {
			var m = NativeString.copy(text, 1, p - 1);
			if (NativeString.copy(m, 1, 2) == "\r\n") m = NativeString.delete(m, 1, 2);
			message = m;
			text = NativeString.delete(text, 1, p - 1 + sep.length);
		}
		// grab stack:
		var vmStart = "\r\nstack frame is\r\n";
		p = NativeString.pos(vmStart, text);
		var prefix:String = "";
		if (p > 0) {
			text = NativeString.delete(text, 1, p - 1 + vmStart.length);
			p = NativeString.pos("\r\n", text);
			if (p > 0) {
				prefix = "called from - " + NativeString.copy(text, 1, p + 1);
				text = NativeString.delete(text, 1, p + 1);
			} else {
				prefix = text;
				text = "";
			}
		} else {
			p = NativeString.pos("called from - ", text);
			if (p > 0) text = NativeString.delete(text, 1, p - 1);
		}
		stack = prefix + text;
		//trace('`$message` `$stack`');
	}
}
#else
@:native("Error")
extern class Error {
	var message:String;
	var name:String;
	var stack(default, null):String;

	function new(?message:String):Void;
}
#end