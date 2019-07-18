package;

import gml.MetaType;
import SfTools.raw;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("")
class Std {
	
	@:remove @:native("is_type")
	public static inline function is(value:Dynamic, type:Dynamic):Bool {
		return StdImpl.is(value, type);
	}
	
	@:extern public static inline function int(float:Float):Int {
		return untyped (float | 0);
	}
	
	@:remove
	public static function string(value:Dynamic):String {
		return raw("string")(value);
	}
	
	/** Returns 0 instead of null on failure. */
	@:remove @:native("real")
	public static function parseFloat(value:String):Float {
		return raw("real")(value);
	}
	
	/** Returns 0 instead of null on failure. */
	public static inline function parseInt(value:String):Int {
		return int(parseFloat(value));
	}
	
	@:native("random_flr")
	public static inline function random(limit:Int):Int {
		return gml.Mathf.irandom(limit - 1);
	}
	
}

@:std @:keep
private class StdImpl {
	public static function isNumber(value:Dynamic):Bool {
		return gml.NativeType.isReal(value)
			|| gml.NativeType.isInt64(value)
			|| gml.NativeType.isInt32(value)
			|| gml.NativeType.isBool(value);
	}
	public static function isInt(value:Dynamic):Bool {
		if (gml.NativeType.isReal(value)) {
			return (value | 0) == value;
		}
		return gml.NativeType.isInt64(value)
			|| gml.NativeType.isInt32(value)
			|| gml.NativeType.isBool(value);
	}
	public static function is<T>(value:Dynamic, type:Class<T>):Bool {
		if (type == null) return false;
		if (Std.is(type, Array)) switch (type) {
			case Float: return inline isNumber(value);
			case Int: return inline isInt(value);
			case String: return Std.is(value, String);
			default: {
				var vt;
				if (MetaType.has(value)) {
					vt = MetaType.get(value);
				} else if (inline isNumber(value)) {
					vt = null;
					for (q in gml.NativeScope.with(value, gml.Instance)) {
						vt = q.getField("__class__");
					}
					if (vt == null) return false;
				} else return false;
				var vti:Int = inline isNumber(vt) ? cast vt : vt.index;
				var tt:MetaType<T> = cast type;
				return MetaType.is.get(vti, tt.index);
			}
		}
		else if (inline isNumber(type)) {
		if (inline isNumber(value)) {
				for (q in gml.NativeScope.with(value, gml.Instance)) {
					return (q.object_index == cast type)
					|| q.object_index.isChildOf(cast type);
				}
			}
		}
		return false;
	}
}
