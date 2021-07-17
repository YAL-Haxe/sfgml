package haxe.ds;
import gml.NativeArray;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
class IntMap<T> extends BasicMap<Int, T> implements haxe.Constraints.IMap<Int,T> {
	#if sfgml.modern
	override private function keysArray():Array<Int> {
		#if (sfgml_version >= "2.3.1")
		var keys:Array<Any> = cast obj.keys();
		for (i in 0 ... keys.length) {
			keys[i] = gml.NativeType.toInt64(keys[i]);
		}
		return cast keys;
		#else
		var keys = cachedKeys;
		if (keys != null) return keys;
		var obj = obj;
		var keys = obj.keys();
		var keyCount = keys.length;
		var resKeys:Array<Int> = NativeArray.createEmpty(keyCount - blanks);
		var resCount = -1;
		var i = -1; while (++i < keyCount) {
			var key = keys[i];
			if (obj[key] != BasicMap.blank) {
				var ik = Std.parseInt(key);
				if (ik != null) resKeys[++resCount] = ik;
			}
		}
		cachedKeys = resKeys;
		return resKeys;
		#end
	}
	#else
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
	#end
}
