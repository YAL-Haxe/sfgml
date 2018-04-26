package gml.ds;

/**
 * Wraps ds_stack_ functions.
 * @author YellowAfterlife
 */
@:std @:native("ds_stack") @:final
extern class Stack<T> {
	function new();
	function destroy():Void;
	function clear():Void;
	//
	@:native("empty") function isEmpty():Bool;
	function size():Int;
	//
	@:native("copy") function copyFrom(source:Stack<T>):Void;
	inline function copyTo(destination:Stack<T>):Void {
		destination.copyFrom(this);
	}
	//
	/// Adds an element to stack
	function push(value:T):Void;
	/// Removes an element from stack
	function pop():T;
	/// Returns the top element without removing it from stack
	@:native("top") function peekTop():T;
	//
	function write():String;
	function read(source:String):Void;
}
