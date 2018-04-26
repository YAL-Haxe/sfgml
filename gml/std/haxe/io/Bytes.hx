package haxe.io;
import gml.io.Buffer;
import gml.io.BufferType;
import gml.NativeArray;
import haxe.Int64;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
@:std class Bytes {
	public var length(get, null):Int;
	inline function get_length():Int {
		return data.length;
	}
	private var data:BytesData;
	
	public inline function new(data:BytesData) {
		this.data = data;
	}
	
	public inline function get(pos:Int):Int {
		return data[pos];
	}
	public inline function set(pos:Int, val:Int) {
		data[pos] = val & 0xff;
	}
	
	public inline function blit(pos:Int, src:Bytes, srcPos:Int, len:Int):Void {
		NativeArray.copyPart(data, pos, src.data, srcPos, len);
	}
	public inline function fill(pos:Int, len:Int, val:Int) {
		BytesImpl.fill(data, pos, len, val);
	}
	
	public inline function sub(pos:Int, len:Int):Bytes {
		return new Bytes(data.slice(pos, len));
	}
	
	public inline function compare(other:Bytes):Int {
		return BytesImpl.compare(data, length, other.data, other.length);
	}
	
	public inline function getUInt16(pos:Int):Int {
		return BytesImpl.getUInt16(data, pos);
	}
	public inline function setUInt16(pos:Int, val:Int) {
		BytesImpl.setUInt16(data, pos, val);
	}
	
	public inline function getInt32(pos:Int):Int {
		return BytesImpl.getInt32(data, pos);
	}
	public inline function setInt32(pos:Int, val:Int) {
		BytesImpl.setInt32(data, pos, val);
	}
	
	public inline function getInt64(pos:Int):Int64 {
		return BytesImpl.getInt64(data, pos);
	}
	public inline function setInt64(pos:Int, val:Int64) {
		BytesImpl.setInt64(data, pos, val);
	}
	
	public inline function getFloat(pos:Int):Float {
		return BytesImpl.getFloat(data, pos);
	}
	public inline function setFloat(pos:Int, val:Float) {
		BytesImpl.setFloat(data, pos, val);
	}
	
	public inline function getDouble(pos:Int):Float {
		return BytesImpl.getDouble(data, pos);
	}
	public inline function setDouble(pos:Int, val:Float) {
		BytesImpl.setDouble(data, pos, val);
	}
	
	public inline function getString(pos:Int, len:Int):String {
		return BytesImpl.getString(data, pos, len);
	}
	public inline function toString():String {
		return BytesImpl.getString(data, 0, length);
	}
	
	public inline function toHex():String {
		return BytesImpl.toHex(data);
	}
	
	public inline function getData():BytesData {
		return data;
	}
	
	public static inline function alloc(size:Int):Bytes {
		return new Bytes(NativeArray.create(size, 0));
	}
	
	public static inline function ofData(d:BytesData):Bytes {
		return new Bytes(d);
	}
	
	public static inline function ofString(s:String):Bytes {
		return new Bytes(BytesImpl.ofString(s));
	}
	
	public static inline function fastGet(d:BytesData, pos:Int):Int {
		return d[pos];
	}
}
private class BytesImpl {
	private static var buffer:Buffer = new Buffer(128, Grow, 1);
	public static function fill(d:BytesData, pos:Int, len:Int, val:Int) {
		while (--len >= 0) d[pos++] = val;
	}
	public static function compare(d1:BytesData, n1:Int, d2:BytesData, n2:Int):Int {
		var n = n1 < n2 ? n1 : n2;
		for (i in 0 ... n) {
			var diff = d1[i] - d2[i];
			if (diff != 0) return diff;
		}
		return n1 - n2;
	}
	
	private static inline function set(d:BytesData, pos:Int, val:Int) {
		d[pos] = val & 0xff;
	}
	
	public static function getUInt16(d:BytesData, pos:Int):Int {
		return d[pos] | (d[pos + 1] << 8);
	}
	public static function setUInt16(d:BytesData, pos:Int, val:Int) {
		set(d, pos, val);
		set(d, pos + 1, val >> 8);
	}
	
	public static function getInt32(d:BytesData, pos:Int):Int {
		return d[pos] | (d[pos + 1] << 8) | (d[pos + 2] << 16) | (d[pos + 3] << 24);
	}
	public static function setInt32(d:BytesData, pos:Int, val:Int) {
		set(d, pos, val);
		set(d, pos + 1, val >> 8);
		set(d, pos + 2, val >> 16);
		set(d, pos + 3, val >> 24);
	}
	
	public static function getInt64(d:BytesData, pos:Int):Int64 {
		return d[pos] | (d[pos + 1] << 8) | (d[pos + 2] << 16) | (d[pos + 3] << 24) |
			(d[pos + 4] << 32) | (d[pos + 5] << 40) | (d[pos + 6] << 48) | (d[pos + 7] << 56);
	}
	public static function setInt64(d:BytesData, pos:Int, val:Int64) {
		set(d, pos, cast val);
		set(d, pos + 1, cast val >> 8);
		set(d, pos + 2, cast val >> 16);
		set(d, pos + 3, cast val >> 24);
		set(d, pos + 4, cast val >> 32);
		set(d, pos + 5, cast val >> 40);
		set(d, pos + 6, cast val >> 48);
		set(d, pos + 7, cast val >> 56);
	}
	
	public static function getFloat(d:BytesData, pos:Int):Float {
		var b = buffer;
		b.rewind();
		for (i in 0 ... 4) b.writeByte(d[pos++]);
		return b.peekFloat(0);
	}
	public static function setFloat(d:BytesData, pos:Int, val:Float) {
		var b = buffer;
		b.pokeFloat(0, val);
		b.rewind();
		for (i in 0 ... 4) d[pos++] = b.readByte();
	}
	
	public static function getDouble(d:BytesData, pos:Int):Float {
		var b = buffer;
		b.rewind();
		for (i in 0 ... 8) b.writeByte(d[pos++]);
		return b.peekDouble(0);
	}
	public static function setDouble(d:BytesData, pos:Int, val:Float) {
		var b = buffer;
		b.pokeDouble(0, val);
		b.rewind();
		for (i in 0 ... 8) d[pos++] = b.readByte();
	}
	
	public static function getString(d:BytesData, pos:Int, len:Int):String {
		var b = buffer;
		b.rewind();
		while (--len >= 0) b.writeByte(d[pos++]);
		b.writeByte(0);
		b.rewind();
		return b.readString();
	}
	
	public static function toHex(d:BytesData):String {
		var b = buffer;
		b.rewind();
		for (i in 0 ... d.length) {
			var v = d[i], h:Int;
			inline function add(q:Int):Void {
				h = q;
				if (h >= 0xA) {
					b.writeByte(h + ("A".code - 10));
				} else b.writeByte(h + "0".code);
			}
			add(v >> 4);
			add(v & 0xF);
		}
		b.writeByte(0);
		b.rewind();
		return b.readString();
	}
	
	public static function ofString(s:String):BytesData {
		var b = buffer;
		b.rewind();
		b.writeChars(s);
		var size = b.position;
		var out = NativeArray.create(size);
		b.rewind();
		for (i in 0 ... size) out[i] = b.readByte();
		return out;
	}
}
#else
abstract Bytes(Buffer) {
	
	public var length(get, never):Int;
	
	public inline function new(n:Int, d:BytesData) {
		this = cast d;
	}
	
	public static inline function alloc(size:Int):Bytes {
		return cast new Buffer(size, gml.io.BufferKind.Fixed, 1);
	}
	
	public inline function destroy() {
		this.destroy();
	}
	
	private inline function get_length() return this.size;
	
	public inline function get(index:Int):Int {
		return this.peekByteUnsigned(index);
	}
	
	public inline function set(index:Int, byte:Int):Void {
		this.pokeByteUnsigned(index, byte);
	}
	
	public inline function blit(pos:Int, src:Bytes, srcpos:Int, len:Int):Void {
		this.copyFrom(pos, cast src, srcpos, len);
	}
	
	public inline function fill(pos:Int, len:Int, value:Int):Void {
		this.fill(pos, BufferType.BYTE_UNSIGNED, value, len);
	}
	
	public function sub(pos:Int, len:Int):Bytes {
		var b:Bytes = alloc(len);
		b.blit(0, cast this, pos, len);
		return b;
	}
	
	public inline function getDouble(pos:Int):Float {
		return this.peekDouble(pos);
	}
	
	public inline function setDouble(pos:Int, val:Float):Void {
		this.pokeDouble(pos, val);
	}
	
	public inline function getFloat(pos:Int):Float {
		return this.peekFloat(pos);
	}
	
	public inline function setFloat(pos:Int, val:Float):Void {
		this.pokeFloat(pos, val);
	}
	
	public inline function getUInt16(pos:Int):Int {
		return this.peekShortUnsigned(pos);
	}
	
	public inline function setUInt16(pos:Int, val:Int):Void {
		this.pokeShortUnsigned(pos, val);
	}
	
	public inline function getInt32(pos:Int):Int {
		return this.peekIntSigned(pos);
	}
	
	public inline function setInt32(pos:Int, val:Int):Void {
		this.pokeIntUnsigned(pos, val);
	}
	
	public inline function getData():BytesData {
		return cast this;
	}
	
	public static inline function ofData(d:BytesData):Bytes {
		return cast d;
	}
	
	public static inline function fastGet(d:BytesData, pos:Int):Int {
		#if (gml && !macro)
		return d.peekByteUnsigned(pos);
		#else
		throw "?";
		#end
	}
	
	public function toString():String {
		var p = this.position;
		this.position = 0;
		var s = this.readString();
		this.position = p;
		return s;
	}
	
	public static function ofString(s:String):Bytes {
		var b = alloc(gml.NativeString.byteLength(s));
		b.getData().writeChars(s);
		return b;
	}
}
#end
