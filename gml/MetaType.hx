package gml;

import gml.ds.Grid;
import gml.MetaType.MetaClass;
import SfTools.raw;

/**
 * Haxe Classes have their "type" stored in first item of second row.
 * This wrapper offers tools for working with that.
 * @author YellowAfterlife
 */
@:native("haxe.type") @:std
#if (sfgml_custom_meta) @:remove #end
class MetaType<T> {
	/** Every type is assigned an index. */
	public var index:Int;
	/** The name of this particular type. */
	public var name:String;
	
	/** <Index1, Index2, Is> */
	@:remove public static var is:Grid<Bool>;
	public static function get<T>(obj:T):MetaType<T> {
		return raw("{0}[1,0]", obj);
	}
	public static function set<T>(obj:T, type:Dynamic):Void {
		raw("{0}[@1,0] = {1}", obj, type);
	}
	@:remove public static function copyset<T>(obj:T, type:Dynamic):Void {
		raw("{0}[1,0] = {1}", obj, type);
	}
	/** Returns whether the object has a metatype. */
	public static inline function has(obj:Dynamic):Bool {
		return (raw("array_height_2d")(obj) > 1);
	}
	@:keep private static function proto<T>(rest:SfRest<Any>):Any {
		var n = rest.length, out:Array<Any>;
		#if (!sfgml_version || sfgml_version > 1763)
		out = NativeArray.create(n);
		#else
		out = null;
		#end
		var i = 0;
		while (i < n) {
			out[i] = rest[i];
			i += 1;
		}
		return out;
	}
}

@:keep @:native("haxe.class") @:std
class MetaClass<T> extends MetaType<T> {
	public var superClass:MetaClass<Dynamic> = null;
	public function new(id:Int, name:String) {
		this.index = id;
		this.name = name;
	}
}

@:keep @:native("haxe.enum") @:std
class MetaEnum<T> extends MetaType<T> {
	public var constructors:Array<String>;
	public function new(id:Int, name:String, ?ctrs:Array<String>) {
		this.index = id;
		this.name = name;
		this.constructors = ctrs;
	}
}
