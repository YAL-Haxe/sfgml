package;

import gml.MetaType;
import SfTools.raw;
import gml.NativeType;
import gml.NativeString;

/**
 * ...
 * @author YellowAfterlife
 */
@:std
class Std {
	
	extern public static inline function is(value:Dynamic, type:Dynamic):Bool {
		return StdImpl.is(value, type);
	}
	
	extern public static inline function int(float:Float):Int {
		return untyped (float | 0);
	}
	
	
	public static function string(value:Dynamic):String {
		if (NativeType.isReal(value)) {
			var s = NativeString.format(value, 0, 16);
			var n:Int, i:Int;
			if (gml.sys.System.isBrowser) {
				n = s.length;
				i = n;
				while (i > 0) {
					switch (NativeString.charCodeAt(s, i)) {
						case "0".code: i -= 1; continue;
						case ".".code: i -= 1; // -> break
						default: // -> break
					}; break;
				}
			} else {
				n = NativeString.byteLength(s);
				i = n;
				while (i > 0) {
					switch (NativeString.byteAt(s, i)) {
						case "0".code: i -= 1; continue;
						case ".".code: i -= 1; // -> break
						default: // -> break
					}; break;
				}
			}
			return NativeString.copy(s, 1, i);
		}
		return NativeType.toString(value);
	}
	
	public static function parseFloat(s:String):Float {
		var n = NativeString.digits(s).length;
		var p = NativeString.pos(".", s);
		var e = NativeString.pos("e", s);
		switch (e) {
			case 0: {};
			case 1: return Math.NaN;
			case 2: if (p > 0) return Math.NaN;
			default: if (p > 0 && e < p) return Math.NaN;
		}
		return (cast n) && n == s.length
			- (cast (s.charCodeAt(0) == "-".code))
			- (cast (p != 0))
			- (cast (e != 0))
		? NativeType.toReal(s) : Math.NaN;
	}
	
	public static function parseInt(value:String):Null<Int> {
		inline function isInt(s:String):Bool {
			var n = NativeString.digits(s).length;
			return (cast n) && n == s.length
				- (cast (s.charCodeAt(0) == "-".code));
		}
		return isInt(value) ? raw("real")(value) : null;
	}
	
	extern public static inline function random(limit:Int):Int {
		return gml.Mathf.irandom(limit - 1);
	}
	
}

@:std @:keep
private class StdImpl {
	public static function is<T>(value:Dynamic, type:Class<T>):Bool {
		inline function isNumber(v:Dynamic) {
			return inline NativeTypeHelper.isNumber(v);
		}
		if (type == null) return false;
		if (Std.is(type, Array)) switch (type) {
			case Float: return isNumber(value);
			case Int: return inline NativeTypeHelper.isIntNumber(value);
			case String: return Std.is(value, String);
			default: {
				var vt;
				if (MetaType.has(value)) {
					vt = MetaType.get(value);
				} else if (isNumber(value)) {
					vt = null;
					for (q in gml.NativeScope.with(value, gml.Instance)) {
						vt = q.getField("__class__");
					}
					if (vt == null) return false;
				} else return false;
				var vti:Int = isNumber(vt) ? cast vt : vt.index;
				var tt:MetaType<T> = cast type;
				return MetaType.is.get(vti, tt.index);
			}
		}
		return false;
	}
}
