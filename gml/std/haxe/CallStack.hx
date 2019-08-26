package haxe;

/**
 * ...
 * @author YellowAfterlife
 */
class CallStack {
	
	public static inline function toString(stack:Array<StackItem>):String {
		return stack.join("\n");
	}
	
	public static inline function callStack():Array<StackItem> {
		return SfTools.raw("debug_get_callstack")();
	}
}

typedef StackItem = Dynamic;
