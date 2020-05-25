package gml;

import gml.NativeArray;
import gml.ds.Grid;
import gml.MetaType.MetaClass;
import SfTools.raw;

/**
 * Haxe Classes have their "type" stored in first item of second row.
 * This wrapper offers tools for working with that.
 * @author YellowAfterlife
 */
@:native("haxe.type") @:std
#if sfgml.modern
@:gml.struct
#end
class MetaType<T> {
	#if !sfgml_legacy_meta
	/** Is used to quickly tell that this is the right thing */
	public var marker:Dynamic;
	#end
	
	/** Every type is assigned an index. */
	public var index:Int;
	
	/** The name of this specific type. */
	public var name:String;
	
	/** <Index1, Index2, Is> */
	@:remove public static var is:Grid<Bool>;
	
	#if !sfgml_legacy_meta
	@:remove public static var markerValue:Dynamic = [];
	
	/** Returns whether the object has a metatype. */
	@:keep public static function has(obj:Dynamic):Bool {
		#if sfgml.modern
		if (NativeType.isStruct(obj)) {
			return NativeStruct.hasField(obj, "__class__");
		}
		#end
		if (NativeArray.length1d(obj) < 1) return false;
		var meta:MetaType<Any> = obj[0];
		#if sfgml.modern
		return NativeType.isStruct(meta)
			&& NativeStruct.getField(meta, "marker") == markerValue;
		#else
		return NativeArray.length1d(cast meta) >= 3
			&& NativeType.isArray(meta.marker)
			&& meta.marker == markerValue;
		#end
	}
	
	#if sfgml.modern
	public static function get<T>(obj:T):MetaType<T> {
		if (NativeType.isStruct(obj)) {
			return (cast obj:Dynamic).__class__;
		} else return (cast obj:Dynamic)[0];
	}
	#else
	public static inline function get<T>(obj:T):MetaType<T> {
		return (cast obj:Dynamic)[0];
	}
	#end
	
	public static inline function set<T>(obj:T, meta:Dynamic):Void {
		(cast obj:Dynamic)[0] = meta;
	}
	#else // -> sfgml_legacy_meta
	
	/** Returns whether the object has a metatype. */
	public static inline function has(obj:Dynamic):Bool {
		return (raw("array_height_2d")(obj) > 1);
	}
	
	public static function get<T>(obj:T):MetaType<T> {
		// checked for in SfGmlType if needed
		return raw("{0}[1,0]", obj);
	}
	
	public static function set<T>(obj:T, type:Dynamic):Void {
		// checked for in SfGmlType if needed
		raw("{0}[@1,0] = {1}", obj, type);
	}
	
	@:remove public static function copyset<T>(obj:T, type:Dynamic):Void {
		raw("{0}[1,0] = {1}", obj, type);
	}
	#end
	
	/** sfgml uses this is we don't have array literals */
	@:keep private static function proto<T>(rest:SfRest<Any>):Any {
		var n = rest.length, out:Array<Any>;
		#if (sfgml_array_create)
		out = NativeArray.createEmpty(n);
		#else
		out = null;
		#end
		var i = 0;
		while (i < n) {
			#if (sfgml_array_create)
			out[i] = rest[i];
			#else
			NativeArray.copyset(out, i, rest[i]);
			#end
			i += 1;
		}
		return out;
	}
}

@:keep @:native("haxe.class") @:std
#if sfgml.modern
@:gml.struct
#end
class MetaClass<T> extends MetaType<T> {
	public var superClass:MetaClass<Dynamic> = null;
	public var constructor:Dynamic;
	public function new(id:Int, name:String, ?constructor:Dynamic) {
		#if !sfgml_legacy_meta
		marker = MetaType.markerValue;
		#end
		this.index = id;
		this.name = name;
		this.constructor = constructor;
	}
}

@:keep @:native("haxe.enum") @:std
#if sfgml.modern
@:gml.struct
#end
class MetaEnum<T> extends MetaType<T> {
	public var constructors:Array<String>;
	public function new(id:Int, name:String, ?constructors:Array<String>) {
		#if !sfgml_legacy_meta
		marker = MetaType.markerValue;
		#end
		this.index = id;
		this.name = name;
		this.constructors = constructors;
	}
}
