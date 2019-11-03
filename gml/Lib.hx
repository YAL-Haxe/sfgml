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
	
	/** A of milliseconds since sometime. Same as getTimer. */
	@:native("current_time") static var currentTime:Int;
	
	/** Returns the number of milliseconds since sometime. */
	static inline function getTimer():Int return currentTime;
	
	@:expose("undefined") static var undefined:Dynamic;
	
	//{ GML-specific features
	
	/** A quick and generally-alright integer division. Result is int32 */
	static inline function div(a:Float, b:Float):Int {
		return untyped __raw__("({0} div {1})", a, b);
	}
	
	//}
	
	/**
	 * Represents the raw array of GML arguments passed to the current function.
	 * Please note that instance functions will contain the applicable instance
	 * as the first argument.
	 */
	static var args(default, never):Arguments;
	
	/**
	 * Indicates the raw number of arguments passed to the current function.
	 * Please note that instance functions will contain the applicable instance
	 * as the first argument.
	 * Equivalent to Lib.args.length
	 */
	@:native("argument_count") static var argc(default, never):Int;
	
	/**
	 * Generates a `untyped __gml__("")` expression in a convenient format.
	 * Intended for referencing built-in functions and variables.
	 * @param	gml
	 * @return
	 */
	@:extern static inline function raw(gml:String):Dynamic {
		return untyped __raw__(gml);
	}
	
	/** Points to "global" scope, just in case you want to do something with it. */
	static var global:GlobalScope;
}
@:object("global") private extern class GlobalScope implements Dynamic { }

@:extern private abstract Arguments(Array<Dynamic>) {
	@:extern @:arrayAccess inline function get(index:Int):Dynamic {
		return untyped __raw__("argument[{0}]", index);
	}
	@:extern @:arrayAccess inline function set(index:Int, value:Dynamic):Dynamic {
		return untyped __raw__("argument[{0}] = {1}]", index, value);
	}
	public var length(get, never):Int;
	@:extern inline function get_length():Int {
		return untyped __raw__("argument_count");
	}
}
