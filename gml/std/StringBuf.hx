package ;
import gml.NativeArray;
import gml.NativeString;
import gml.io.Buffer;
import haxe.io.BytesData;

/**
 * 
 * @author YellowAfterlife
 */
#if !sfgml_native_stringbuf
@:std class StringBuf {
	private var str:String = "";
	private var strLen:Int = 0;
	private static inline var strMax:Int = 128;
	
	private var arr:Array<String> = NativeArray.create(arrMax0);
	private var arrLen:Int = 0;
	private var arrMax:Int = arrMax0;
	private static inline var arrMax0 = 4;
	
	private static var buffer:Buffer = new Buffer(128, Grow, 1);
	
	public var length(default, null):Int = 0;
	
	public function new() {
		//
	}
	private function store() {
		var i = arrLen++;
		var m = arrMax;
		var arr = this.arr;
		if (i >= m) {
			m *= 2;
			arr[m - 1] = null;
			arrMax = m;
		}
		arr[i] = str;
		str = "";
		strLen = 0;
	}
	public function addChar(c:Int):Void {
		str += String.fromCharCode(c);
		length += 1;
		if (++strLen >= strMax) store();
	}
	public function add<T>(val:T):Void {
		var s = Std.string(val);
		var n = NativeString.byteLength(s);
		str += s;
		length += n;
		strLen += n;
		if (strLen >= strMax) store();
	}
	public function addSub(s:String, pos:Int, ?len:Int):Void {
		var s = len != null ? s.substr(pos, len) : s.substr(pos);
		var n = NativeString.byteLength(s);
		str += s;
		length += n;
		strLen += n;
		if (strLen >= strMax) store();
	}
	public function toString():String {
		var arr = this.arr;
		var buf = buffer;
		buf.rewind();
		for (i in 0 ... arrLen) {
			buf.writeChars(arr[i]);
		}
		buf.writeString(str);
		buf.rewind();
		return buf.readString();
	}
}
#else
@:std class StringBuf {
	private var buf:Buffer = new Buffer(32, Grow, 1);
	public var length(get, never):Int;
	private inline function get_length():Int {
		return buf.position;
	}
	
	public inline function new() {
		//
	}
	public inline function destroy() {
		if (buf != Buffer.defValue) {
			buf.destroy();
			buf = Buffer.defValue;
		}
	}
	
	public inline function addChar(c:Int):Void {
		buf.writeChars(String.fromCharCode(c));
	}
	
	public inline function add<T>(val:T):Void {
		buf.writeChars(Std.string(val));
	}
	
	public inline function addSub(s:String, pos:Int, ?len:Int):Void {
		if (len != null) {
			buf.writeChars(s.substr(pos, len));
		} else buf.writeChars(s.substr(pos));
	}
	
	public inline function toString() {
		buf.writeByte(0);
		buf.rewind();
		var s = buf.readString();
		buf.destroy();
		buf = Buffer.defValue;
		return s;
	}
}
#end
