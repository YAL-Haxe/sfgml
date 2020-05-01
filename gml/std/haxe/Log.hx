package haxe;

/**
 * ...
 * @author YellowAfterlife
 */
@:remove class Log {
	
	public static function formatOutput( v : Dynamic, infos : PosInfos ) : String {
		var str = Std.string(v);
		if (infos == null) return str;
		var pstr = infos.fileName + ":" + infos.lineNumber;
		if (infos != null && infos.customParams != null) {
			for (v in infos.customParams) str += ", " + Std.string(v);
		}
		return pstr+": "+str;
	}
	
	public static
	#if sf_dynamic_trace
	dynamic
	#end
	function trace( v : Dynamic, ?infos : PosInfos ) : Void {
		SfTools.raw("show_debug_message")(formatOutput(v, infos));
	}

}
