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
	@:native("empty") function isEmpty():Bool;
	function size():Int;
	
	function dequeue():Null<T>;
	function enqueue(values:Rest<T>):Void;
	
	function head():Null<T>;
	function tail():Null<T>;
	
	@:native("copy") function copyFrom(source:Queue<T>):Void;
	
	function read(data:String):Void;
	function write():String;
}
