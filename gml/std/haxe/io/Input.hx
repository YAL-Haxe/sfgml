package haxe.io;

import gml.NativeArray;
import gml.io.Buffer;
import gml.io.BufferKind;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
class Input {
	/**
	 * It is faster to write some bytes into a temp buffer and then read back
	 * a value using a built-in function than do floating-point construction yourself.
	 */
	private static var buffer:Buffer = new Buffer(32, Grow, 1);
	
	private var data:BytesData;
	private var dataPos:Int = 0;
	private var dataLen:Int;
	public var bigEndian:Bool = false;
	public dynamic function close() {
		//
	}
	
	public function readByte():Int {
		var d = data; return d[dataPos++];
	}
	public function readInt8():Int {
		var d = data;
		var n = d[dataPos++];
		return n >= 0x80 ? n - 0x100 : n;
	}
	
	private inline function readUInt16Impl() {
		var d = data;
		var p = dataPos;
		var c1 = d[p++];
		var c2 = d[p++];
		dataPos = p;
		return bigEndian ? (c1 << 8) | c2 : c1 | (c2 << 8);
	}
	public function readUInt16():Int {
		return readUInt16Impl();
	}
	public function readInt16():Int {
		var n = readUInt16Impl();
		return n >= 0x8000 ? n - 0x10000 : n;
	}
	
	private inline function readUInt24Impl() {
		var d = data;
		var p = dataPos;
		var c1 = d[p++];
		var c2 = d[p++];
		var c3 = d[p++];
		dataPos = p;
		return bigEndian ? (c1 << 16) | (c2 << 8) | c3 : c1 | (c2 << 8) | (c3 << 16);
	}
	public function readUInt24():Int {
		return readUInt16Impl();
	}
	public function readInt24():Int {
		var n = readUInt16Impl();
		return n >= 0x800000 ? n - 0x1000000 : n;
	}
	
	public function readInt32():Int {
		var d = data;
		var p = dataPos;
		var c1 = d[p++];
		var c2 = d[p++];
		var c3 = d[p++];
		var c4 = d[p++];
		dataPos = p;
		var n = bigEndian
			? (c1 << 24) | (c2 << 16) | (c3 << 8) | c4
			: c1 | (c2 << 8) | (c3 << 16) | (c4 << 24);
		// (don't forget, 64-bit integers)
		return n >= 0x80000000 ? n - cast 4294967296 : n;
	}
	
	public function readFloat():Float {
		var d = data;
		var p = dataPos;
		var buf = buffer;
		var i:Int;
		if (bigEndian) {
			i = 4; while (--i >= 0) buf.pokeByte(i, d[p++]);
		} else {
			i = 0; while (i < 4) buf.pokeByte(i++, d[p++]);
		}
		dataPos = p;
		return buf.peekFloat(0);
	}
	
	public function readDouble():Float {
		var d = data;
		var p = dataPos;
		var buf = buffer;
		var i:Int;
		if (bigEndian) {
			i = 8; while (--i >= 0) buf.pokeByte(i, d[p++]);
		} else {
			i = 0; while (i < 8) buf.pokeByte(i++, d[p++]);
		}
		dataPos = p;
		return buf.peekDouble(0);
	}
	
	public function readBytes(to:Bytes, pos:Int, len:Int):Int {
		var start = dataPos;
		var avail = dataLen - start;
		if (len > avail) len = avail;
		NativeArray.copyPart(to.getData(), pos, data, start, len);
		dataPos = start + len;
		return len;
	}
	
	public inline function readFullBytes(to:Bytes, pos:Int, len:Int):Void {
		// no exception handling so can't throw Blocked
		readBytes(to, pos, len);
	}
	
	public function readAll(?bufSize:Int):Bytes {
		var start = dataPos;
		var till = dataLen;
		var size = till - start;
		var out = NativeArray.createEmpty(size);
		NativeArray.copyPart(out, 0, data, start, size);
		dataPos = till;
		return Bytes.ofData(out);
	}
	
	public function read(len:Int):Bytes {
		var start = dataPos;
		var avail = dataLen - start;
		if (len > avail) len = avail;
		var out = NativeArray.createEmpty(len);
		NativeArray.copyPart(out, 0, data, start, len);
		dataPos = start + len;
		return Bytes.ofData(out);
	}
	
	public function readUntil(endc:Int):String {
		var b = buffer;
		b.rewind();
		var pos = dataPos;
		var data = this.data;
		var len = dataLen;
		while (pos < len) {
			var next = data[pos++];
			if (next != endc) {
				b.writeByte(next);
			} else break;
		}
		dataPos = pos;
		b.writeByte(0);
		b.rewind();
		return b.readString();
	}
	
	public function readLine():String {
		var buf = buffer;
		buf.rewind();
		var pos = dataPos;
		var data = this.data;
		var len = dataLen;
		var last = -1;
		while (pos < len) {
			var next = data[pos++];
			if (next != "\n".code) {
				buf.writeByte(next);
				last = next;
			} else break;
		}
		if (last == "\r".code) buf.shiftPosition( -1);
		buf.writeByte(0);
		buf.rewind();
		dataPos = pos;
		return buf.readString();
	}
	
	public function readString(count:Int):String {
		var pos = dataPos;
		var data = this.data;
		var maxLen = dataLen - pos;
		if (count > maxLen) count = maxLen;
		var buf = buffer;
		buf.rewind();
		for (_ in 0 ... count) buf.writeByte(data[pos++]);
		buf.writeByte(0);
		buf.rewind();
		dataPos = pos;
		return buf.readString();
	}
}
#else
class Input {
	private var buf:Buffer;
	//
	public inline function close():Void {
		buf.destroy();
	}
	//
	public inline function readByte():Int return buf.readByte();
	public inline function readInt8():Int return buf.readByteSigned();
	public inline function readUInt16():Int return buf.readShortUnsigned();
	public inline function readInt16():Int return buf.readShortSigned();
	public inline function readInt32():Int return buf.readIntSigned();
	//
	private static function readStringImpl(buf:Buffer, len:Int):String {
		var out = new Buffer(len + 1, Fixed, 1);
		var pos = buf.position;
		var lim = buf.size - pos;
		if (len > lim) len = lim;
		out.copyFrom(0, buf, pos, len);
		buf.position = pos + len;
		out.pokeByte(len, 0);
		var str = out.readString();
		out.destroy();
		return str;
	}
	public inline function readString(len:Int):String return readStringImpl(buf, len);
	//
	private static function readBytesImpl(buf:Buffer, out:Buffer, pos:Int, len:Int):Int {
		// todo: recheck if 
		var bufLen = buf.size;
		var bufPos = buf.position;
		var maxLen = bufLen - bufPos;
		if (maxLen <= 0) return -1;
		if (len > maxLen) len = maxLen;
		if (len > 0) {
			out.copyFrom(pos, buf, bufPos, len);
			buf.shiftPosition(len);
		}
		return len;
	}
	public inline function readBytes(b:Bytes, pos:Int, len:Int):Int {
		return readBytesImpl(buf, b.getData(), pos, len);
	}
	//
}
#end
