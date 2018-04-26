package haxe.ds;

import gml.Lib;
import haxe.ds.*;
import haxe.Constraints.IMap;

/**
 * If situation permits, please prefer using -D sfgml_native_map or gml.ds.HashTable directly.
 * @author YellowAfterlife
 */
#if (display||macro||eval||!sfgml_native_map)
@:multiType(@:followWithAbstracts K)
abstract Map<K,V>(IMap<K,V>) {
	public function new();

	public inline function set(key:K, value:V) this.set(key, value);

	@:arrayAccess public inline function get(key:K) return this.get(key);

	public inline function exists(key:K) return this.exists(key);

	public inline function remove(key:K) return this.remove(key);

	public inline function keys():Iterator<K> {
		return this.keys();
	}

	public inline function iterator():Iterator<V> {
		return this.iterator();
	}

	public inline function copy():Map<K,V> {
		return cast this.copy();
	}

	public inline function toString():String {
		return this.toString();
	}

	@:arrayAccess @:noCompletion public inline function arrayWrite(k:K, v:V):V {
		this.set(k, v);
		return v;
	}

	@:to static inline function toStringMap<K:String,V>(t:IMap<K,V>):StringMap<V> {
		return new StringMap<V>();
	}

	@:to static inline function toIntMap<K:Int,V>(t:IMap<K,V>):IntMap<V> {
		return new IntMap<V>();
	}

	@:from static inline function fromStringMap<V>(map:StringMap<V>):Map< String, V > {
		return cast map;
	}

	@:from static inline function fromIntMap<V>(map:IntMap<V>):Map< Int, V > {
		return cast map;
	}
}
#else
import SfTools.raw;
import gml.ds.HashTable;

@:forward(destroy, exists, remove, get, set, keys, iterator, toString)
abstract Map<K, V>(HashTable<K, V>) from HashTable<K, V> to HashTable<K, V> {
	public inline function new() {
		this = raw("ds_map_create")();
	}
	
	//
	@:arrayAccess inline function arrayRead(key:K):V {
		return this.get(key);
	}
	@:arrayAccess inline function arrayWrite(key:K, value:V):V {
		this.set(key, value);
		return value;
	}
}
#end
