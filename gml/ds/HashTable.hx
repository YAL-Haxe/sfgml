package gml.ds;
import SfTools.raw;

/**
 * Wraps ds_map_ functions.
 * Internally those probably wrap std::map or something.
 * @author YellowAfterlife
 */
@:forward @:forwardStatics @:docName("ds_map")
abstract HashTable<K, V>(HashTableImpl<K, V>) from HashTableImpl<K, V> to HashTableImpl<K, V> {
	public static inline var defValue:Dynamic = cast -1;
	
	public static inline function isValid<K, V>(map:HashTable<K, V>):Bool {
		return raw("ds_exists")(map, raw("ds_type_map"));
	}
	
	public inline function new() {
		this = raw("ds_map_create")();
	}
	
	@:arrayAccess inline function arrayRead(key:K):V {
		return this.get(key);
	}
	@:arrayAccess inline function arrayWrite(key:K, value:V):V {
		this.set(key, value);
		return value;
	}
	
	public static inline function parse(json:String):HashTable<String, Dynamic> {
		return raw("json_decode")(json);
	}
}

@:native("ds_map") @:final @:snakeCase
private extern class HashTableImpl<K, V> {
	static inline var defValue:Any = cast -1;
	//
	function new();
	function destroy():Void;
	//
	function clear():Void;
	@:pure @:native("empty") function isEmpty():Bool;
	@:pure function size():Int;
	//
	private static function copy<K, V>(to:HashTableImpl<K, V>, from:HashTableImpl<K, V>):Void;
	inline function copyFrom(from:HashTableImpl<K, V>):Void {
		copy(this, from);
	}
	//
	@:pure @:native("find_value") function get(key:K):Null<V>;
	function set(key:K, value:V):Void;
	@:pure function exists(key:K):Bool;
	@:native("delete") function remove(key:K):Void;
	//
	function add(key:K, value:V):Bool;
	function addMap<K1, V1>(key:K, map:HashTable<K1, V1>):Void;
	function addList<T>(key:K, map:ArrayList<T>):Void;
	//
	@:native("find_first") function findFirst():K;
	@:native("find_next") function findNext(after:K):K;
	@:native("find_last") function findLast():K;
	@:native("find_previous") function findPrevious(before:K):K;
	//
	@:native("secure_load") static function secureLoad<K, V>(fileName:String):HashTableImpl<K, V>;
	@:native("secure_save") function secureSave(fileName:String):Bool;
	//
	function read(string:String):Void;
	function write():String;
	
	inline function keys():HashTableKeyIterator<K,V> {
		return new HashTableKeyIterator(this);
	}
	inline function iterator():HashTableValueIterator<K,V> {
		return new HashTableValueIterator(this);
	}
	@:expose("json_encode") function toString():String;
}

@:native("ds_map_key_iterator")
@:nativeGen class HashTableKeyIterator<K, V> {
	var map:HashTableImpl<K, V>;
	var key:K;
	@:runtime public inline function new(map:HashTableImpl<K, V>) {
		this.map = map;
		this.key = this.map.findFirst();
	}
	@:runtime public inline function hasNext() {
		return key != null;
	}
	@:runtime public inline function next():K {
		var out = key;
		key = map.findNext(key);
		return out;
	}
}

@:native("ds_map_value_iterator")
@:nativeGen class HashTableValueIterator<K, V> {
	var map:HashTableImpl<K, V>;
	var key:K;
	@:runtime public inline function new(map:HashTableImpl<K, V>) {
		this.map = map;
		this.key = this.map.findFirst();
	}
	@:runtime public inline function hasNext() {
		return key != null;
	}
	@:runtime public inline function next():V {
		var out = map.get(key);
		key = map.findNext(key);
		return out;
	}
}

