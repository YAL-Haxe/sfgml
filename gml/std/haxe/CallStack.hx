package haxe;

/**
 * ...
 * @author YellowAfterlife
 */
class CallStack {
	
	@:extern public static inline function callStack():Array<Dynamic> {
		return SfTools.raw("debug_get_callstack")();
	}
}
