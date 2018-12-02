package haxe.ds;
import gml.NativeArray;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
class IntMap<T> extends BasicMap<Int, T> implements haxe.Constraints.IMap<Int,T> {
	private inline function hashOf(s:Int) {
		return rawHash(function(b:Buffer) {
			b.writeInt(s);
		});
	}
	public function get(k:Int):Null<T> {
		return rawGet(hashOf(k), k);
	}
	public function exists(k:Int):Bool {
		return rawCheck(hashOf(k), k);
	}
	public function set(k:Int, v:T):Void {
		rawPut(hashOf(k), k, v);
	}
	public function remove(k:Int):Bool {
		return rawRemove(hashOf(k), k);
	}
	public function keys():Iterator<Int> {
		return rawKeys().iterator();
	}
	public inline function iterator():Iterator<T> {
		return rawValues().iterator();
	}
	public inline function keyValueIterator():KeyValueIterator<Int, T> {
		throw "not implemented";
	}
	public function copy():IntMap<T> {
		var next:IntMap<T> = new IntMap<T>();
		rawCopy(next);
		return next;
	}
	public function toString():String {
		return rawPrint();
	}
}
