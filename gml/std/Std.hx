package;

import gml.MetaType;
import SfTools.raw;
import gml.NativeStruct;
import gml.NativeType;
import gml.NativeString;
import gml.internal.StdTypeImpl;

/**
 * ...
 * @author YellowAfterlife
 */
@:std
class Std {
	
	extern public static inline function is(value:Dynamic, type:Dynamic):Bool {
		return StdTypeImpl.is(value, type);
	}
	
	#if (haxe >= "4.1.0")
	extern public static inline function isOfType(value:Dynamic, type:Dynamic):Bool {
		return StdTypeImpl.is(value, type);
	}
	#end
	
	public static inline function downcast<T:{}, S:T>(value:T, c:Class<S>):S @:privateAccess {
		return if (StdTypeImpl.is(value, c)) cast value else null;
	}
	
	extern public static inline function int(float:Float):Int {
		return untyped (float | 0);
	}
	
	@:keep public static function string(value:Dynamic):String {
		if (value == null) return "null";
		if (NativeType.isString(value)) return value;
		var n:Int, i:Int, s:String;
		#if sfgml.modern
		if (NativeType.isStruct(value)) {
			var e:MetaEnum<Dynamic> = NativeStruct.getField(value, "__enum__");
			if (e == null) return NativeType.toString(value);
			var ects = e.constructors;
			if (ects != null) {
				i = untyped value.__enumIndex__;
				if (i >= 0 && i < ects.length) {
					s = ects[i];
				} else s = "?";
			} else {
				s = NativeStruct.instanceOf(value);
				if (NativeString.copy(s, 1, 3) == "mc_") {
					s = NativeString.delete(s, 1, 3);
				}
				n = e.name.length;
				if (NativeString.copy(s, 1, n) == e.name) {
					s = NativeString.delete(s, 1, n + 1);
				}
			}
			s += "(";
			var fields:Array<String> = untyped value.__enumParams__;
			n = fields.length;
			i = -1; while (++i < n) {
				if (i > 0) s += ", ";
				s += Std.string(NativeStruct.getField(value, fields[i]));
			}
			return s + ")";
		}
		#end
		if (NativeType.isReal(value)) {
			s = NativeString.format(value, 0, 16);
			if (gml.sys.System.isBrowser) {
				// it is obviously tempting to just ""+s but this could change in future.
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
		var l = s.length;
		var n = NativeString.digits(s).length;
		var p = NativeString.pos(".", s);
		var e = NativeString.pos("e", s);
		if (e == 0) e = NativeString.pos("E", s); // allow "1E2"
		switch (e) {
			case 0: {};
			case 1: return Math.NaN;
			case 2: if (p > 0) return Math.NaN;
			default: if (p > 0 && e < p) return Math.NaN;
		}
		// allow "1e+1" / "1e-1"
		if (e != 0 && e < l - 1) switch (NativeString.charCodeAt(s, e + 1)) {
			case "+".code, "-".code: l--;
		}
		return (cast n) && n == l
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
