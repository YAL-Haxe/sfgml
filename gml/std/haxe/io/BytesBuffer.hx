package haxe.io;
import gml.NativeArray;
import gml.io.Buffer;
import haxe.Int64;
import haxe.io.Bytes;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
@:coreApi
class BytesBuffer {
	var buffer:Array<Int> = [];
	var pos:Int = 0;
	var size:Int = 0;
	
	public var length(get, never):Int;
	inline function get_length():Int {
		return pos;
	}
	
	public function new() {
		//
	}
	
	public function addByte(byte:Int):Void {
		if (pos == size) grow(1);
		buffer[pos++] = byte & 0xFF;
	}
	
	public function add(src:Bytes):Void {
		var n = src.length;
		if (pos + n > size) grow(1);
		NativeArray.copyPart(buffer, pos, src.getData(), 0, n);
		pos += n;
	}
	
	private static var gmlBuffer:Buffer = new Buffer(128, Grow, 1);
	public function addString(v:String, ?encoding:Encoding):Void {
		var b = gmlBuffer;
		b.rewind();
		b.writeChars(v);
		var n = b.position;
		if (pos + n > size) grow(n);
		var i = -1; while (++i < n) {
			buffer[pos + i] = b.peekByte(i);
		}
		pos += n;
		//add(Bytes.ofString(v, encoding));
	}
	
	public function addInt32(v:Int):Void {
		if (pos + 4 > size) grow(4);
		var b = gmlBuffer;
		b.pokeIntSigned(0, v);
		for (i in 0 ... 4) {
			buffer[pos + i] = b.peekByte(i);
		}
		pos += 4;
	}
	
	public function addInt64(v:Int64):Void {
		if (pos + 8 > size) grow(8);
		var b = gmlBuffer;
		b.pokeInt64(0, v);
		for (i in 0 ... 8) {
			buffer[pos + i] = b.peekByte(i);
		}
		pos += 8;
	}
	
	public function addFloat(v:Float):Void {
		if (pos + 4 > size) grow(4);
		var b = gmlBuffer;
		b.pokeFloat(0, v);
		for (i in 0 ... 4) {
			buffer[pos + i] = b.peekByte(i);
		}
		pos += 4;
	}
	
	public function addDouble(v:Float):Void {
		if (pos + 8 > size) grow(8);
		var b = gmlBuffer;
		b.pokeDouble(0, v);
		for (i in 0 ... 8) {
			buffer[pos + i] = b.peekByte(i);
		}
		pos += 8;
	}
	
	public function addBytes(src:Bytes, pos:Int, len:Int):Void {
		if (pos < 0 || len < 0 || pos + len > src.length) throw Error.OutsideBounds;
		if (this.pos + len > size) grow(len);
		if (size == 0) return;
		NativeArray.copyPart(buffer, this.pos, src.getData(), pos, len);
		this.pos += len;
	}
	
	function grow(delta:Int):Void {
		var req = pos + delta;
		var nsize = size == 0 ? 16 : size;
		while (nsize < req) nsize = (nsize * 3) >> 1;
		buffer.resize(nsize);
	}
	
	public function getBytes():Bytes @:privateAccess {
		if (size == 0) return Bytes.alloc(0);
		var b = new Bytes(buffer);
		b.length = pos;
		return b;
	}
}
#else
//@:coreApi // extra field: destroy()
class BytesBuffer {
	var buffer:Buffer;
	
	public var length(get, never):Int;
	inline function get_length():Int {
		return buffer.position;
	}
	
	public function new() {
		buffer = new Buffer(128, Grow, 1);
	}
	public function destroy():Void {
		buffer.destroy();
	}
	public function addByte(byte:Int):Void {
		buffer.writeByteUnsigned(byte);
	}
	public function add(src:Bytes):Void {
		buffer.writeBuffer(src.getData());
	}
	public function addString(v:String, ?encoding:Encoding):Void {
		// TODO: encoding
		buffer.writeChars(v);
	}
	public function addInt32(v:Int):Void {
		buffer.writeInt(v);
	}
	public function addInt64(v:Int64):Void {
		buffer.writeInt64(v);
	}
	public function addFloat(v:Float):Void {
		buffer.writeFloat(v);
	}
	public function addDouble(v:Float):Void {
		buffer.writeDouble(v);
	}
	public function addBytes(src:Bytes, pos:Int, len:Int):Void {
		buffer.writeBufferExt(src.getData(), pos, len);
	}
	public function getBytes():Bytes {
		var n = length;
		var bytes = Bytes.alloc(n);
		bytes.getData().copyFrom(0, buffer, 0, n);
		return bytes;
	}
}
#end
