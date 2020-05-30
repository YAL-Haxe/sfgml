package gml.assets;
import gml.assets.Asset;
import SfTools.raw;
import haxe.Constraints.Function;

/**
 * Scripts are functions in GML, but also a resource type.
 * @author YellowAfterlife
 */
@:std @:native("script")
extern class Script extends Asset {
	public static inline var defValue:Script = cast -1;
	
	/** Returns whether the given script index exists */
	@:native("exists")
	public static function isValid(q:Script):Bool;
	
	public var name(get, never):String;
	private function get_name():String;
	
	/** Casts the script to a numeric index */
	public var index(get, never):Int;
	private inline function get_index():Int {
		return cast this;
	}
	
	/** Allows the script to be called with arbitrary arguments - e.g. scr_some.call(1) */
	public var call(get, never):ScriptCallable;
	private inline function get_call():ScriptCallable {
		return cast this;
	}
	
	/** Casts the script to a function type */
	public inline function asFunc<T:Function>():T {
		return cast this;
	}
	
	/** Casts a numeric index to a script resource */
	public static inline function fromIndex(i:Int):Script {
		return cast i;
	}
	
	/** Casts a function reference to a script resource */
	public static inline function fromFunc(fn:Function):Script {
		return cast fn;
	}
}

private typedef ScriptCallable = haxe.extern.Rest<Dynamic>->Dynamic;

