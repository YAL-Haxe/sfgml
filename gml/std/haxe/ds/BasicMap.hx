package haxe.ds;
import gml.NativeArray;
import gml.io.Buffer;
import haxe.DynamicAccess;
import haxe.Constraints.IMap;

#if sfgml.modern
class BasicMap<K, V> implements haxe.Constraints.IMap<K, V> {
	var obj:DynamicAccess<V> = {};
	
	public function new() {}
	
	#if (sfgml_version >= "2.3.1")
	
	public function copy():IMap<K, V> {
		var keys = obj.keys();
		var result = new BasicMap<K, V>();
		var resObj = result.obj;
		for (key => val in obj) {
			resObj[key] = val;
		}
		return result;
	}
	
	public function clear() {
		for (key in obj.keys()) {
			obj.remove(key);
		}
	}
	
	public inline function exists(key:K):Bool {
		return obj.exists(cast key);
	}
	
	public inline function get(key:K):V {
		return obj.get(cast key);
	}
	public inline function set(key:K, val:V):Void {
		obj[cast key] = val;
	}
	public inline function remove(key:K):Bool {
		return obj.remove(cast key);
	}
	
	#else
	
	static var blank:Dynamic = [];
	
	/** Number of "holes" (removed pairs) in this structure */
	var blanks:Int = 0;
	
	var cachedKeys:Array<K> = null;
	
	public function copy():IMap<K, V> {
		var obj = obj;
		var blank = blank;
		var result = new BasicMap<K, V>();
		var resObj = result.obj;
		//
		var keys = obj.keys();
		var keyCount = keys.length;
		var i = -1;
		var key:String;
		if (blanks > 0) while (++i < keyCount) {
			key = keys[i];
			var val = obj[key];
			if (val != blank) resObj[key] = val;
		}
		else while (++i < keyCount) {
			key = keys[i];
			resObj[key] = obj[key];
		}
		return result;
	}
	
	public function clear():Void {
		var obj = obj;
		var keys = obj.keys();
		var keyCount = keys.length;
		if (blanks == keyCount) return; // already empty
		var blank = blank;
		var i = -1; while (++i < keyCount) {
			obj[keys[i]] = blank;
		}
		blanks = keyCount;
	}
	
	public function exists(key:K):Bool {
		return obj.exists(cast key) && (blanks <= 0 || obj[cast key] != blank);
	}
	
	public function get(key:K):Null<V> {
		var val = obj[cast key];
		return val != blank ? val : null;
	}
	
	public function set(key:K, val:V):Void {
		if (blanks > 0) {
			var cachedKeys = cachedKeys;
			if (cachedKeys != null) {
				if (obj.exists(cast key)) {
					if (obj[cast key] == blank) blanks--;
				} else {
					cachedKeys[cachedKeys.length] = key;
				}
			} else {
				if (obj[cast key] == blank) blanks--;
			}
		}
		obj[cast key] = val;
	}
	
	public function remove(key:K):Bool {
		if (obj.exists(cast key)) {
			if (blanks > 0) {
				if (obj[cast key] == blank) return false;
				cachedKeys = null;
			}
			obj[cast key] = blank;
			blanks++;
			return true;
		} else return false;
	}
	
	#end
	
	function keysArray():Array<K> {
		throw "Should be implemented in the specific Map class";
	}
	public function keys():Iterator<K> {
		return keysArray().iterator();
	}
	
	public function iterator():Iterator<V> {
		return new BasicMapIterator(this);
	}
	
	public function keyValueIterator():KeyValueIterator<K, V> {
		return new BasicMapKeyValueIterator(this);
	}
	
	static var toString_buf:Buffer = Buffer.defValue;
	public function toString():String {
		var b = toString_buf;
		if (b == Buffer.defValue) {
			b = new Buffer(1024, Grow, 1);
			toString_buf = b;
		}
		b.rewind();
		b.writeChars("{");
		var keys = obj.keys();
		for (i in 0 ... keys.length) {
			if (i > 0) b.writeChars(", ");
			var k = keys[i];
			b.writeChars(k);
			b.writeChars(" => ");
			b.writeChars(Std.string(obj[k]));
		}
		b.writeString("}");
		b.rewind();
		return b.readString();
	}
}

class BasicMapIterator<K, V> {
	final access:DynamicAccess<V>;
	final keys:Array<K>;
	var index:Int;

	public inline function new(map:BasicMap<K, V>) {
		this.access = @:privateAccess map.obj;
		this.keys = @:privateAccess map.keysArray();
		index = 0;
	}
	
	public inline function hasNext():Bool {
		return index < keys.length;
	}
	
	public inline function next():V {
		return access.get(cast keys[index++]);
	}
}

class BasicMapKeyValueIterator<K, V> {
	final access:DynamicAccess<V>;
	final keys:Array<K>;
	var index:Int;

	public inline function new(map:BasicMap<K, V>) {
		this.access = @:privateAccess map.obj;
		this.keys = @:privateAccess map.keysArray();
		index = 0;
	}
	
	public inline function hasNext():Bool {
		return index < keys.length;
	}
	
	public inline function next():{key:K, value:V} {
		var key = keys[index++];
		return {value: access.get(cast key), key: key};
	}
}

#else
/**
 * A rough port of
 * https://github.com/petewarden/c_hashmap
 * There are most certainly fancier options.
 * @author YellowAfterlife
 */
class BasicMap<K, V> {
	private static inline var initialSize:Int = 256;
	private static inline var maxChainLen:Int = 8;
	private static var buffer = new Buffer(32, Grow, 1);
	
	public var tableSize:Int = initialSize;
	public var size:Int = 0;
	public var pairs:Array<BasicMapPair<K, V>>;
	
	public function new() {
		pairs = NativeArray.create(initialSize, BasicMapPair.defValue);
	}
	public function clear() {
		var i = tableSize;
		while (--i >= 0) pairs[i] = BasicMapPair.defValue;
		size = 0;
	}
	
	#if !sfgml.modern
	private static var crc32tab = [ //{
		0x00000000,0x77073096,0xee0e612c,0x990951ba,0x076dc419,0x706af48f,0xe963a535,0x9e6495a3,
		0x0edb8832,0x79dcb8a4,0xe0d5e91e,0x97d2d988,0x09b64c2b,0x7eb17cbd,0xe7b82d07,0x90bf1d91,
		0x1db71064,0x6ab020f2,0xf3b97148,0x84be41de,0x1adad47d,0x6ddde4eb,0xf4d4b551,0x83d385c7,
		0x136c9856,0x646ba8c0,0xfd62f97a,0x8a65c9ec,0x14015c4f,0x63066cd9,0xfa0f3d63,0x8d080df5,
		0x3b6e20c8,0x4c69105e,0xd56041e4,0xa2677172,0x3c03e4d1,0x4b04d447,0xd20d85fd,0xa50ab56b,
		0x35b5a8fa,0x42b2986c,0xdbbbc9d6,0xacbcf940,0x32d86ce3,0x45df5c75,0xdcd60dcf,0xabd13d59,
		0x26d930ac,0x51de003a,0xc8d75180,0xbfd06116,0x21b4f4b5,0x56b3c423,0xcfba9599,0xb8bda50f,
		0x2802b89e,0x5f058808,0xc60cd9b2,0xb10be924,0x2f6f7c87,0x58684c11,0xc1611dab,0xb6662d3d,
		0x76dc4190,0x01db7106,0x98d220bc,0xefd5102a,0x71b18589,0x06b6b51f,0x9fbfe4a5,0xe8b8d433,
		0x7807c9a2,0x0f00f934,0x9609a88e,0xe10e9818,0x7f6a0dbb,0x086d3d2d,0x91646c97,0xe6635c01,
		0x6b6b51f4,0x1c6c6162,0x856530d8,0xf262004e,0x6c0695ed,0x1b01a57b,0x8208f4c1,0xf50fc457,
		0x65b0d9c6,0x12b7e950,0x8bbeb8ea,0xfcb9887c,0x62dd1ddf,0x15da2d49,0x8cd37cf3,0xfbd44c65,
		0x4db26158,0x3ab551ce,0xa3bc0074,0xd4bb30e2,0x4adfa541,0x3dd895d7,0xa4d1c46d,0xd3d6f4fb,
		0x4369e96a,0x346ed9fc,0xad678846,0xda60b8d0,0x44042d73,0x33031de5,0xaa0a4c5f,0xdd0d7cc9,
		0x5005713c,0x270241aa,0xbe0b1010,0xc90c2086,0x5768b525,0x206f85b3,0xb966d409,0xce61e49f,
		0x5edef90e,0x29d9c998,0xb0d09822,0xc7d7a8b4,0x59b33d17,0x2eb40d81,0xb7bd5c3b,0xc0ba6cad,
		0xedb88320,0x9abfb3b6,0x03b6e20c,0x74b1d29a,0xead54739,0x9dd277af,0x04db2615,0x73dc1683,
		0xe3630b12,0x94643b84,0x0d6d6a3e,0x7a6a5aa8,0xe40ecf0b,0x9309ff9d,0x0a00ae27,0x7d079eb1,
		0xf00f9344,0x8708a3d2,0x1e01f268,0x6906c2fe,0xf762575d,0x806567cb,0x196c3671,0x6e6b06e7,
		0xfed41b76,0x89d32be0,0x10da7a5a,0x67dd4acc,0xf9b9df6f,0x8ebeeff9,0x17b7be43,0x60b08ed5,
		0xd6d6a3e8,0xa1d1937e,0x38d8c2c4,0x4fdff252,0xd1bb67f1,0xa6bc5767,0x3fb506dd,0x48b2364b,
		0xd80d2bda,0xaf0a1b4c,0x36034af6,0x41047a60,0xdf60efc3,0xa867df55,0x316e8eef,0x4669be79,
		0xcb61b38c,0xbc66831a,0x256fd2a0,0x5268e236,0xcc0c7795,0xbb0b4703,0x220216b9,0x5505262f,
		0xc5ba3bbe,0xb2bd0b28,0x2bb45a92,0x5cb36a04,0xc2d7ffa7,0xb5d0cf31,0x2cd99e8b,0x5bdeae1d,
		0x9b64c2b0,0xec63f226,0x756aa39c,0x026d930a,0x9c0906a9,0xeb0e363f,0x72076785,0x05005713,
		0x95bf4a82,0xe2b87a14,0x7bb12bae,0x0cb61b38,0x92d28e9b,0xe5d5be0d,0x7cdcefb7,0x0bdbdf21,
		0x86d3d2d4,0xf1d4e242,0x68ddb3f8,0x1fda836e,0x81be16cd,0xf6b9265b,0x6fb077e1,0x18b74777,
		0x88085ae6,0xff0f6a70,0x66063bca,0x11010b5c,0x8f659eff,0xf862ae69,0x616bffd3,0x166ccf45,
		0xa00ae278,0xd70dd2ee,0x4e048354,0x3903b3c2,0xa7672661,0xd06016f7,0x4969474d,0x3e6e77db,
		0xaed16a4a,0xd9d65adc,0x40df0b66,0x37d83bf0,0xa9bcae53,0xdebb9ec5,0x47b2cf7f,0x30b5ffe9,
		0xbdbdf21c,0xcabac28a,0x53b39330,0x24b4a3a6,0xbad03605,0xcdd70693,0x54de5729,0x23d967bf,
		0xb3667a2e,0xc4614ab8,0x5d681b02,0x2a6f2b94,0xb40bbe37,0xc30c8ea1,0x5a05df1b,0x2d02ef8d,
	]; //}
	private static function crc32get(b:Buffer) {
		var n = b.position;
		var val = 0;
		var tab = crc32tab;
		b.rewind();
		while (--n >= 0) {
			val = tab[(val ^ b.readByte()) & 0xff] ^ (val >> 8);
		}
		// todo: is hashmap_hash_int postfix worth it
		return (val >>> 0);
	}
	#else
	private static inline function crc32get(b:Buffer) {
		return b.crc32(0, b.position);
	}
	#end
	private inline function rawHash(fn:Buffer->Void):Int {
		var b = buffer;
		b.rewind();
		fn(b);
		return crc32get(b);
	}
	private inline function rawGetImpl<T>(hash:Int, key:K, fn:Bool->BasicMapPair<K, V>->T):T {
		var tableSize = this.tableSize;
		var curr = hash % tableSize;
		var pairs = this.pairs;
		var result:BasicMapPair<K, V> = BasicMapPair.defValue;
		for (i in 0 ... maxChainLen) {
			var item = pairs[curr];
			if (item != BasicMapPair.defValue && item.used && item.key == key) {
				result = item;
				break;
			}
			curr = (curr + 1) % tableSize;
		}
		return fn(result != BasicMapPair.defValue, result);
	}
	private inline function rawGet(hash:Int, key:K):Null<V> {
		return rawGetImpl(hash, key, function(found, item) {
			if (found) {
				return item.value;
			} else return null;
		});
	}
	private inline function rawCheck(hash:Int, key:K):Bool {
		return rawGetImpl(hash, key, function(found, item) {
			return found;
		});
	}
	private inline function rawRemove(hash:Int, key:K):Bool {
		return rawGetImpl(hash, key, function(found, item) {
			if (found) {
				item.key = null;
				item.value = null;
				item.used = false;
				size -= 1;
				return true;
			} else return false;
		});
	}
	private function rawRehash() {
		var currSize = tableSize;
		var curr = pairs;
		var nextSize = currSize * 2;
		var next:Array<BasicMapPair<K, V>>;
		next = NativeArray.create(nextSize, BasicMapPair.defValue);
		tableSize = nextSize;
		size = 0;
		pairs = next;
		for (i in 0 ... currSize) {
			var item = curr[i];
			if (item != BasicMapPair.defValue && item.used) {
				rawPut(item.hash, item.key, item.value);
			}
		}
	}
	private function rawPrepare(hash:Int, key:K):BasicMapPair<K, V> {
		var tableSize = this.tableSize;
		if (size >= tableSize / 2) return null;
		var curr = hash % tableSize;
		var pairs = this.pairs;
		for (i in 0 ... maxChainLen) {
			var item = pairs[curr];
			if (item == BasicMapPair.defValue) {
				item = new BasicMapPair();
				pairs[curr] = item;
				size += 1;
				return item;
			} else if (!item.used || item.key == key) return item;
			curr = (curr + 1) % tableSize;
		}
		return null;
	}
	private inline function rawPut(hash:Int, key:K, val:V):V {
		var item = rawPrepare(hash, key);
		while (item == null) {
			rawRehash();
			item = rawPrepare(hash, key);
		}
		item.used = true;
		item.hash = hash;
		item.key = key;
		item.value = val;
		return val;
	}
	private inline function rawIterImpl(fn:BasicMapPair<K, V>->Void):Void {
		var pairs = this.pairs;
		var tableSize = this.tableSize;
		for (i in 0 ... tableSize) {
			var item = pairs[i];
			if (item != BasicMapPair.defValue && item.used) fn(item);
		}
	}
	private inline function rawFindAllImpl<T>(fn:BasicMapPair<K, V>->T):Array<T> {
		var out = NativeArray.createEmpty(size);
		var found = 0;
		rawIterImpl(function(item) {
			out[found++] = fn(item);
		});
		return out;
	}
	private inline function rawKeys():Array<K> {
		return rawFindAllImpl(function(item) {
			return item.key;
		});
	}
	private inline function rawValues():Array<V> {
		return rawFindAllImpl(function(item) {
			return item.value;
		});
	}
	private inline function rawCopy(next:BasicMap<K, V>):Void {
		next.size = size;
		var tableSize = this.tableSize;
		var nextPairs;
		if (next.tableSize != tableSize) {
			nextPairs = NativeArray.createEmpty(tableSize);
			next.pairs = nextPairs;
			next.tableSize = tableSize;
		} else nextPairs = next.pairs;
		NativeArray.copyPart(nextPairs, 0, pairs, 0, tableSize);
	}
	private inline function rawPrint():String {
		var b = buffer;
		b.rewind();
		var first = true;
		b.writeChars("{");
		rawIterImpl(function(item) {
			if (first) {
				first = false;
				b.writeByte(" ".code);
			} else b.writeChars(", ");
			b.writeChars(Std.string(item.key));
			b.writeChars(" => ");
			b.writeChars(Std.string(item.value));
		});
		b.writeString(" }");
		b.rewind();
		return b.readString();
	}
}
@:nativeGen class BasicMapPair<K, V> {
	public static inline var defValue:Dynamic = null;
	public var hash:Int;
	public var key:K;
	public var value:V;
	public var used:Bool;
	public function new() { }
}
#end