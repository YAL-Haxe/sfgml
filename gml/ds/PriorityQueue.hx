package gml.ds;

/**
 * Wraps ds_priority_ functions.
 * @author YellowAfterlife
 */
@:std @:native("ds_priority") @:final
extern class PriorityQueue<T> {
	function new();
	function destroy():Void;
	function clear():Void;
	//
	@:native("empty") function isEmpty():Bool;
	function size():Int;
	//
	@:native("copy") function copyFrom(source:PriorityQueue<T>):Void;
	inline function copyTo(destination:PriorityQueue<T>):Void {
		destination.copyFrom(this);
	}
	//
	function add(value:T, priority:Float):Void;
	function change(value:T, priority:Float):Void;
	@:native("delete_value") function delete(value:T):Void;
	@:native("find_priority") function find(value:T):Null<Float>;
	//
	@:native("delete_min") function deleteMin():T;
	@:native("delete_max") function deleteMax():T;
	//
	@:pure @:native("find_min") function findMin():T;
	@:pure @:native("find_max") function findMax():T;
	//
	function write():String;
	function read(source:String):Void;
}
