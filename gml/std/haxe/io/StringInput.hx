package haxe.io;
import gml.NativeArray;
import gml.NativeString;
import gml.io.Buffer;
import gml.io.BufferKind;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
class StringInput extends Input {
	//
	public var position(get, set):Int;
	private inline function get_position():Int return dataPos;
	private inline function set_position(p:Int):Int dataPos = p;
	//
	public var length(get, never):Int;
	private inline function get_length():Int return dataLen;
	//
	private static inline var new_buf:Buffer = Buffer.defValue;
	public inline function new(s:String) {
		var b = new_buf;
		if (b == null) {
			b = new Buffer(NativeString.byteLength(s), Grow, 1);
			new_buf = b;
		}
		b.rewind();
		b.writeChars(s);
		var n = b.position;
		var d = NativeArray.createEmpty(n);
		var i = -1; while (++i < n) {
			d[i] = b.peekByte(i);
		}
		data = d;
		dataLen = n;
	}
}
#else
class StringInput extends Input {
	//
	public var position(get, set):Int;
	private inline function get_position():Int return buf.tell();
	private inline function set_position(p:Int):Int { buf.seek(Start, p); return p; }
	//
	public var length(get, never):Int;
	private inline function get_length():Int return buf.size;
	//
	public inline function new(s:String) {
		buf = new Buffer(gml.NativeString.byteLength(s), BufferKind.FIXED, 1);
		buf.pokeChars(0, s);
	}
}
#end