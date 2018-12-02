package gml.ds;
import SfTools.raw;
import haxe.extern.Rest;
/**
 * Wraps ds_list in a convenient interface.
 * Has to be manually destroyed, but otherwise is much like conventional
 * ArrayList<T> classes in languages
 * @author YellowAfterlife
 */
#if (display || macro)
extern class ArrayList<T> implements ArrayAccess<T> {
	static inline var defValue:Dynamic = cast -1;
	static function isValid<T>(val:ArrayList<T>):Bool;
	//
	function new():Void;
	function destroy():Void;
	function clear():Void;
	var length(default, null):Int;
	//
	@:pure function get(index:Int):T;
	function set(index:Int, val:T):Void;
	//
	function add(values:Rest<T>):Void;
	function insert(index:Int, value:T):Void;
	function remove(value:T):Void;
	function delete(index:Int):Void;
	@:pure function indexOf(value:T):Int;
	//
	function shuffle():Void;
	function sort(ascend:Bool):Void;
	//
	function copyFrom(src:ArrayList<T>):Void;
	function copyTo(dst:ArrayList<T>):Void;
	//
	function iterator():Iterator<T>;
	function keys():IntIterator;
	//
	function toString():String;
}
#else
@:native("ds.list") @:docName("ds_list")
@:forward abstract ArrayList<T>(ArrayListImpl<T>) from ArrayListImpl<T> to ArrayListImpl<T> {
	public static inline var defValue:Dynamic = cast -1;
	
	public static inline function isValid<T>(list:ArrayList<T>):Bool {
		return raw("ds_exists")(list, raw("ds_type_list"));
	}
	
	public inline function new() {
		this = raw("ds_list_create")();
	}
	
	@:arrayAccess inline function arrayRead(index:Int):T {
		return this.get(index);
	}
	@:arrayAccess inline function arrayWrite(index:Int, value:T):T {
		this.set(index, value);
		return value;
	}
	
	public inline function copyFrom(source:ArrayList<T>):Void {
		ArrayListImpl.copy(cast this, cast source);
	}
	public inline function copyTo(destination:ArrayList<T>):Void {
		ArrayListImpl.copy(cast destination, cast this);
	}
	
	#if (sfgml_version && sfgml_version <= "1.4.1763")
	@:native("find_index_safe")
	private static function indexOfSafe<T>(q:ArrayListImpl<T>, v:T):Int {
		for (i in 0 ... q.length) {
			if (q.get(i) == v) return i;
		}
		return -1;
	}
	public inline function indexOf(v:T):Int {
		return indexOfSafe(this, v);
	}
	public inline function remove(v:T):Void {
		this.delete(indexOfSafe(this, v));
	}
	#end
	public inline function iterator() {
		return new ArrayListIterator<T>(this);
	}
	public inline function keys() {
		return new IntIterator(0, this.length);
	}
	public function toString():String {
		var n = this.length;
		var r = "[";
		for (i in 0 ... n) {
			if (i > 0) r += ", ";
			r += Std.string(this.get(i));
		}
		return r + "]";
	}
}

@:native("ds_list") @:final
private extern class ArrayListImpl<T> {
	public var length(get, never):Int;
	@:pure @:native("size") private function get_length():Int;
	@:pure function size():Int;
	//
	function new();
	function destroy():Void;
	function clear():Void;
	//
	static function copy<T>(to:ArrayListImpl<T>, from:ArrayListImpl<T>):Void;
	// Returns whether the list is empty.
	@:pure @:native("empty") function isEmpty():Bool;
	//
	function add(values:haxe.extern.Rest<T>):Void;
	//
	@:pure @:native("find_value") function get(index:Int):T;
	//
	@:pure @:native("find_index") function indexOf(value:T):Int;
	//
	function set(index:Int, value:T):Void;
	/**
	 * This function will add the given value into the list at the given position.
	 * If the list contains more values after the given position,
	 * their position will be shifted up one to make room making the list larger by one. 
	 */
	function insert(position:Int, value:T):Void;
	
	function delete(position:Int):Void;
	inline function remove(value:T):Void {
		delete(indexOf(value));
	}
	//
	function read(string:String):Void;
	function write():String;
	//
	function shuffle():Void;
	function sort(ascend:Bool):Void;
}

@:nativeGen private class ArrayListIterator<T> {
	var list:ArrayListImpl<T>;
	var index:Int;
	public inline function new(subject:ArrayListImpl<T>) {
		list = subject;
		index = 0;
	}
	public inline function hasNext():Bool return index < list.length;
	public inline function next():T return list.get(index++);
}
#end
