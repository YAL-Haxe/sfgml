package haxe.ds;
import gml.NativeArray;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
class StringMap<T> extends BasicMap<String, T> implements haxe.Constraints.IMap<String,T> {
	#if sfgml.modern
	override private function keysArray():Array<String> {
		var keys = cachedKeys;
		if (keys != null) return keys;
		if (blanks > 0) {
			var obj = obj;
			var keys = obj.keys();
			var keyCount = keys.length;
			var resKeys:Array<String> = NativeArray.createEmpty(keyCount - blanks);
			var resCount = -1;
			var i = -1; while (++i < keyCount) {
				var key = keys[i];
				if (obj[key] != BasicMap.blank) {
					resKeys[++resCount] = key;
				}
			}
			cachedKeys = resKeys;
			return resKeys;
		} else {
			return obj.keys();
		}
	}
	#else
	private inline function hashOf(s:String) {
		return rawHash(function(b:Buffer) {
			b.writeChars(s);
		});
	}
	public function get(k:String):Null<T> {
		return rawGet(hashOf(k), k);
	}
	public function exists(k:String):Bool {
		return rawCheck(hashOf(k), k);
	}
	public function set(k:String, v:T):Void {
		rawPut(hashOf(k), k, v);
	}
	public function remove(k:String):Bool {
		return rawRemove(hashOf(k), k);
	}
	public function keys():Iterator<String> {
		return rawKeys().iterator();
	}
	public inline function iterator():Iterator<T> {
		return rawValues().iterator();
	}
	public inline function keyValueIterator():KeyValueIterator<String, T> {
		throw "not implemented";
	}
	public function copy():StringMap<T> {
		var next:StringMap<T> = new StringMap<T>();
		rawCopy(next);
		return next;
	}
	public function toString():String {
		return rawPrint();
	}
	#end
}
