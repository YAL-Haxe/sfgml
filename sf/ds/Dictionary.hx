package sf.ds;
import gml.ds.HashTable;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("ds_map")
@:forward(destroy, clear, set, exists, remove)
abstract Dictionary<K, V>(HashTable<K, V>) {
	//
	public inline function new() this = new HashTable<K, V>();
	//
	@:native("defget")
	public function get(key:K, def:V):V {
		return this.exists(key) ? this.get(key) : def;
	}
	public inline function nget(key:K):Null<V> {
		return this.get(key);
	}
	@:arrayAccess public inline function rget(key:K):V {
		return this.get(key);
	}
	//
	@:arrayAccess private inline function rset(key:K, val:V):V {
		this.set(key, val); return val;
	}
}
