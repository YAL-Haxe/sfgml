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
	
	public static function trace( v : Dynamic, ?infos : PosInfos ) : Void {
		gml.Lib.trace(formatOutput(v, infos));
	}

}
