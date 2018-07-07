package;
import haxe.extern.Rest;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("ds_queue")
extern class Queue<T> {
	function new():Void;
	function destroy():Void;
	
	function clear():Void;
	@:pure @:native("empty") function isEmpty():Bool;
	@:pure function size():Int;
	
	function dequeue():Null<T>;
	function enqueue(values:Rest<T>):Void;
	
	@:pure function head():Null<T>;
	@:pure function tail():Null<T>;
	
	@:native("copy") function copyFrom(source:Queue<T>):Void;
	
	function read(data:String):Void;
	function write():String;
}
