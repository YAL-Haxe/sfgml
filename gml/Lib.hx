package gml;
import SfTools.raw;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("")
extern class Lib {
	/** Outputs the value to stdout and/or the IDE "dock" */
	@:native("show_debug_message") static function trace(value:Dynamic):Void;
	
	/** Emits a native show_error without using Haxe exceptions */
	@:expose("show_error") static function error(text:String, fatal:Bool):Void;
	
	/** A of milliseconds since sometime. Same as getTimer. */
	@:native("current_time") static var currentTime:Int;
	
	/** Returns the number of milliseconds since sometime. */
	static inline function getTimer():Int return currentTime;
	
	/** Returns a native callstack via debug_get_callstack */
	@:expose("debug_get_callstack")
	static function getCallStack():Array<String>;
	
	/**
	 * However, GML's `undefined` is the same as `null` in Haxe,
	 * and GML does not have an equivalent of JS `undefined`
	 * (wrong field access throws errors)
	 */
	@:expose("undefined") static var undefined:Dynamic;
	
	//{ GML-specific features
	
	@:noCompletion @:deprecated("Use Syntax.div instead")
	static inline function div(a:Float, b:Float):Int {
		return untyped __raw__("({0} div {1})", a, b);
	}
	
	//}
	
	/**
	 * Represents the raw array of GML arguments passed to the current function.
	 * Please note that non-static functions may take `this` as a prefix-argument.
	 * Consider using SfRest for this to be handled automatically.
	 */
	static var args(default, never):Arguments;
	
	/**
	 * Indicates the raw number of arguments passed to the current function.
	 * Please note that non-static functions may take `this` as a prefix-argument.
	 * Equivalent to Lib.args.length
	 */
	@:native("argument_count") static var argc(default, never):Int;
	
	@:noCompletion @:extern static inline function raw(gml:String):Dynamic {
		return untyped __raw__(gml);
	}
	
	/** Points to "global" scope, just in case you want to do something with it. */
	static var global:GlobalScope;
}
@:object("global") private extern class GlobalScope implements Dynamic { }

private abstract Arguments(Array<Dynamic>) {
	@:arrayAccess extern inline function get(index:Int):Dynamic {
		return untyped __raw__("argument[{0}]", index);
	}
	@:arrayAccess extern inline function set(index:Int, value:Dynamic):Dynamic {
		return untyped __raw__("argument[{0}] = {1}]", index, value);
	}
	public var length(get, never):Int;
	extern private inline function get_length():Int {
		return untyped __raw__("argument_count");
	}
}
