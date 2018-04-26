package haxe.ds;
import gml.NativeArray;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
class StringMap<T> extends BasicMap<String, T> implements haxe.Constraints.IMap<String,T> {
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
	public function copy():StringMap<T> {
		var next:StringMap<T> = new StringMap<T>();
		rawCopy(next);
		return next;
	}
	public function toString():String {
		return rawPrint();
	}
}
