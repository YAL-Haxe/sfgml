package haxe.io;
import gml.NativeArray;
import gml.io.Buffer;
import haxe.io.Bytes;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
class Output {
	private static inline var dataLen0 = 32;
	private var data:BytesData = NativeArray.create(dataLen0, 0);
	private var dataPos:Int = 0;
	private var dataLen:Int = dataLen0;
	public var bigEndian:Bool = false;
	
	private static var buffer:Buffer = new Buffer(32, Grow, 1);
	
	public dynamic function flush():Void {
		
	}
	
	public dynamic function close():Void {
		
	}
	
	private inline function prepareImpl(data:BytesData, next:Int):Void {
		var dlen = dataLen;
		if (next > dlen) {
			do {
				dlen *= 2;
			} while (next > dlen);
			dlen *= 2;
			data[dlen - 1] = 0;
			dataLen = dlen;
		}
	}
	public function prepare(nbytes:Int):Void {
		var p1 = dataPos + nbytes;
		prepareImpl(data, dataPos + nbytes);
	}
	
	private inline function writeRaw(data:BytesData, pos:Int, val:Int):Void {
		data[pos] = val & 0xff;
	}
	public function writeByte(c:Int):Void {
		var p0 = dataPos;
		var p1 = p0 + 1;
		var d = data;
		prepareImpl(d, p1);
		writeRaw(d, p0, c);
		dataPos = p1;
	}
	public inline function writeInt8(c:Int):Void {
		writeByte(c);
	}
	
	public function writeUInt16(x:Int):Void {
		var p0 = dataPos;
		var p1 = p0 + 2;
		var d = data;
		prepareImpl(d, p1);
		if (bigEndian) {
			writeRaw(d, p0, x >> 8);
			writeRaw(d, p0 + 1, x);
		} else {
			writeRaw(d, p0, x);
			writeRaw(d, p0 + 1, x >> 8);
		}
		dataPos = p1;
	}
	public inline function writeInt16(x:Int):Void {
		writeUInt16(x);
	}
	
	public function writeUInt24(x:Int):Void {
		var p0 = dataPos;
		var p1 = p0 + 3;
		var d = data;
		prepareImpl(d, p1);
		if (bigEndian) {
			writeRaw(d, p0, x >> 16);
			writeRaw(d, p0 + 1, x >> 8);
			writeRaw(d, p0 + 2, x);
		} else {
			writeRaw(d, p0, x);
			writeRaw(d, p0 + 1, x >> 8);
			writeRaw(d, p0 + 2, x >> 16);
		}
		dataPos = p1;
	}
	public inline function writeInt24(x:Int):Void {
		writeUInt24(x);
	}
	
	public function writeInt32(x:Int):Void {
		var p0 = dataPos;
		var p1 = p0 + 4;
		var d = data;
		prepareImpl(d, p1);
		if (bigEndian) {
			writeRaw(d, p0, x >> 24);
			writeRaw(d, p0 + 1, x >> 16);
			writeRaw(d, p0 + 2, x >> 8);
			writeRaw(d, p0 + 3, x);
		} else {
			writeRaw(d, p0, x);
			writeRaw(d, p0 + 1, x >> 8);
			writeRaw(d, p0 + 2, x >> 16);
			writeRaw(d, p0 + 3, x >> 24);
		}
		dataPos = p1;
	}
	
	public function writeFloat(x:Float):Void {
		var p0 = dataPos;
		var p1 = p0 + 4;
		var d = data;
		prepareImpl(d, p1);
		var buf = buffer;
		buf.pokeFloat(0, x);
		var i:Int;
		if (bigEndian) {
			i = 4; while (--i >= 0) d[p0++] = buf.peekByte(i);
		} else {
			i = 0; while (i < 4) d[p0++] = buf.peekByte(i++);
		}
		dataPos = p1;
	}
	
	public function writeDouble(x:Float):Void {
		var p0 = dataPos;
		var p1 = p0 + 8;
		var d = data;
		prepareImpl(d, p1);
		var buf = buffer;
		buf.pokeDouble(0, x);
		var i:Int;
		if (bigEndian) {
			i = 8; while (--i >= 0) d[p0++] = buf.peekByte(i);
		} else {
			i = 0; while (i < 8) d[p0++] = buf.peekByte(i++);
		}
		dataPos = p1;
	}
	
	public function write(b:Bytes):Void {
		var bd = b.getData();
		var bn = bd.length;
		var p0 = dataPos;
		var p1 = p0 + bn;
		var d = data;
		prepareImpl(d, p1);
		NativeArray.copyPart(d, p0, bd, 0, bn);
		dataPos = p1;
	}
	public function writeBytes(b:Bytes, pos:Int, len:Int):Int {
		var bd = b.getData();
		var p0 = dataPos;
		var p1 = p0 + len;
		var d = data;
		prepareImpl(d, p1);
		NativeArray.copyPart(d, p0, bd, pos, len);
		dataPos = p1;
		return len;
	}
	public inline function writeFullBytes(b:Bytes, pos:Int, len:Int):Void {
		writeBytes(b, pos, len);
	}
	
	public function writeString(s:String):Void {
		var buf = buffer;
		buf.rewind();
		buf.writeChars(s);
		var sn = buf.position;
		buf.rewind();
		var p0 = dataPos;
		var p1 = p0 + sn;
		var d = data;
		prepareImpl(d, p1);
		while (p0 < p1) d[p0++] = buf.readByte();
		dataPos = p1;
	}
	
	@:access(haxe.io.Input.data)
	@:access(haxe.io.Input.dataPos)
	@:access(haxe.io.Input.dataLen)
	public function writeInput(q:Input, ?bufSize:Int):Void {
		var q0 = q.dataPos;
		var q1 = q.dataLen;
		var qn = q1 - q0;
		var p0 = dataPos;
		var p1 = p0 + qn;
		var d = data;
		prepareImpl(d, p1);
		NativeArray.copyPart(d, p0, q.data, q0, qn);
		q.dataPos = q1;
		dataPos = p1;
	}
}
#else
class Output {
	private var buf:Buffer;
	
	public inline function writeByte(b:Int):Void buf.writeByteUnsigned(b);
	public inline function writeInt8(i:Int):Void buf.writeByteSigned(i);
	public inline function writeUInt16(u:Int):Void buf.writeShortUnsigned(u);
	public inline function writeInt16(i:Int):Void buf.writeShortSigned(i);
	public inline function writeInt32(i:Int):Void buf.writeInt(i);
	public inline function writeFloat(f32:Float):Void buf.writeFloat(f32);
	public inline function writeDouble(f64:Float):Void buf.writeFloat(f64);
	
	private static function writeBytesImpl(b:Buffer, src:Bytes, pos:Int, len:Int):Int {
		var bPos = b.position;
		var bLen = b.size;
		var nPos = bPos + len;
		if (nPos > bLen) {
			do {
				bLen *= 2;
			} while (nPos > bLen);
			b.resize(bLen);
		}
		b.copyFrom(bPos, src.getData(), pos, len);
		b.position = nPos;
		return len;
	}
	public inline function writeBytes(src:Bytes, pos:Int, len:Int):Int {
		return writeBytesImpl(buf, src, pos, len);
	}
	
	private static function prepareImpl(buf:Buffer, len:Int):Void {
		var bPos = buf.position;
		var bLen = buf.size;
		var nPos = bPos + len;
		if (nPos > bLen) {
			do {
				bLen *= 2;
			} while (nPos > bLen);
			buf.resize(bLen);
		}
	}
	public inline function prepare(len:Int):Void {
		prepareImpl(buf, len);
	}
	
	public inline function flush():Void {
		//
	}
	
	public function close():Void {
		buf.destroy();
	}
}
#end
