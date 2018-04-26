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

@:keep @:native("is")
private class StdImpl {
	@:keep @:native("type")
	public static function is<T>(value:Dynamic, type:Class<T>):Bool {
		if (type == null) return false;
		if (Std.is(type, Array)) switch (type) {
			case Float: return Std.is(value, Float);
			case Int: return Std.is(value, Float) && Std.int(value) == value;
			case String: return Std.is(value, String);
			default: {
				var vt;
				if (MetaType.has(value)) {
					vt = MetaType.get(value);
				} else if (Std.is(value, Float)) {
					vt = null;
					for (q in gml.NativeScope.with(value, gml.Instance)) {
						vt = q.getField("__class__");
					}
					if (vt == null) return false;
				} else return false;
				var vti:Int = Std.is(vt, Float) ? cast vt : vt.index;
				var tt:MetaType<T> = cast type;
				return MetaType.is.get(vti, tt.index);
			}
		}
		else if (Std.is(type, Float)) {
			if (Std.is(value, Float)) {
				for (q in gml.NativeScope.with(value, gml.Instance)) {
					return (q.object_index == cast type)
					|| q.object_index.isChildOf(cast type);
				}
			}
		}
		return false;
	}
}
