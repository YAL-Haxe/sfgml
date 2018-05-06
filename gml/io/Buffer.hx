package gml.io;
import gml.io.BufferType;

/**
 * GameMaker buffers are much like Flash API buffers,
 * but have to be deallocated explicitly.
 * @author YellowAfterlife
 */
@:native("buffer") @:final extern class Buffer {
	public static inline var defValue:Buffer = cast -1;
	public static function sizeof(t:BufferType):Int;
	
	/** Size of buffer, in bytes. */
	public var size(get, never):Int;
	private function get_size():Int;
	
	/** Alias for `size` */
	public var length(get, never):Int;
	private inline function get_length():Int return get_size();
	
	/** As set in constructor */
	public var kind(get, never):BufferKind;
	@:native("get_type") private function get_kind():BufferKind;
	
	/** Current reading/writing position in the buffer. */
	public var position(get, set):Int;
	private inline function get_position():Int return tell();
	private inline function set_position(p:Int):Int {
		seek(BufferSeek.Start, p);
		return p;
	}
	public inline function rewind():Void seek(BufferSeek.Start, 0);
	public inline function shiftPosition(offset:Int):Void {
		seek(BufferSeek.Relative, offset);
	}
	public function tell():Int;
	public function seek(mode:BufferSeek, offset:Int):Void;
	
	public function new(size:Int, kind:BufferKind, alignment:Int);
	
	/** Removes a previously created buffer from the memory. */
	@:native("delete") public function destroy():Void;
	
	public function resize(newSize:Int):Void;
	
	@:native("copy") public function copyTo(offset:Int, size:Int, destBuf:Buffer, destOffset:Int):Void;
	public inline function copyFrom(offset:Int, srcBuffer:Buffer, srcOffset:Int, srcSize:Int):Void {
		srcBuffer.copyTo(srcOffset, srcSize, this, offset);
	}
	
	public function fill(pos:Int, type:BufferType, value:Dynamic, bytes:Int):Void;
	
	//{ Read
	public function read(type:BufferType):Dynamic;
	inline function readBool():Bool return read(bool);
	//
	inline function readByteSigned():Int return read(s8);
	inline function readByteUnsigned():Int return read(u8);
	inline function readByte():Int return read(u8);
	//
	inline function readShortSigned():Int return read(s16);
	inline function readShortUnsigned():Int return read(u16);
	inline function readShort():Int return read(u16);
	//
	inline function readIntSigned():Int return read(s32);
	inline function readIntUnsigned():Int return read(u32);
	inline function readInt():Int return read(s32);
	//
	inline function readFloat():Float return read(f32);
	inline function readDouble():Float return read(f64);
	inline function readString():String return read(string);
	//}
	
	//{ Write
	public function write(type:BufferType, value:Dynamic):Void;
	inline function writeBool(b:Bool):Void write(bool, b);
	//
	inline function writeByteSigned(byte:Int):Void write(s8, byte);
	inline function writeByteUnsigned(ubyte:Int):Void write(u8, ubyte);
	inline function writeByte(ubyte:Int):Void write(u8, ubyte);
	//
	inline function writeShortSigned(short:Int):Void write(s16, short);
	inline function writeShortUnsigned(ushort:Int):Void write(u16, ushort);
	inline function writeShort(ushort:Int):Void write(u16, ushort);
	//
	inline function writeIntSigned(int:Int):Void write(s32, int);
	inline function writeIntUnsigned(uint:Int):Void write(u32, uint);
	inline function writeInt(int:Int):Void write(s32, int);
	//
	inline function writeFloat(float:Float):Void write(f32, float);
	inline function writeDouble(double:Float):Void write(f64, double);
	//
	inline function writeString(str:String):Void write(string, str);
	inline function writeChars(chars:String):Void write(text, chars);
	//
	inline function writeBuffer(src:Buffer):Bool {
		return BufferImpl.writeBuffer(this, src);
	}
	inline function writeBufferExt(src:Buffer, srcPos:Int, srcLen:Int):Bool {
		return BufferImpl.writeBufferExt(this, src, srcPos, srcLen);
	}
	//}
	
	//{ Peek
	public function peek(pos:Int, type:BufferType):Dynamic;
	inline function peekBool(pos:Int):Bool return peek(pos, bool);
	//
	inline function peekByteSigned(pos:Int):Int return peek(pos, s8);
	inline function peekByteUnsigned(pos:Int):Int return peek(pos, u8);
	inline function peekByte(pos:Int):Int return peek(pos, u8);
	//
	inline function peekShortSigned(pos:Int):Int return peek(pos, s16);
	inline function peekShortUnsigned(pos:Int):Int return peek(pos, u16);
	inline function peekShort(pos:Int):Int return peek(pos, u16);
	//
	inline function peekIntSigned(pos:Int):Int return peek(pos, s16);
	inline function peekIntUnsigned(pos:Int):Int return peek(pos, u16);
	inline function peekInt(pos:Int):Int return peek(pos, s16);
	//
	inline function peekFloat(pos:Int):Float return peek(pos, f32);
	inline function peekDouble(pos:Int):Float return peek(pos, f64);
	//
	inline function peekString(pos:Int):String return peek(pos, string);
	//}
	
	//{ Poke
	public function poke(pos:Int, type:BufferType, value:Dynamic):Void;
	inline function pokeBool(pos:Int, val:Bool):Void poke(pos, bool, val);
	//
	inline function pokeByteSigned(pos:Int, byte:Int):Void poke(pos, s8, byte);
	inline function pokeByteUnsigned(pos:Int, ubyte:Int):Void poke(pos, u8, ubyte);
	inline function pokeByte(pos:Int, ubyte:Int):Void poke(pos, u8, ubyte);
	//
	inline function pokeShortSigned(pos:Int, short:Int):Void poke(pos, s16, short);
	inline function pokeShortUnsigned(pos:Int, ushort:Int):Void poke(pos, u16, ushort);
	inline function pokeShort(pos:Int, ushort:Int):Void poke(pos, u16, ushort);
	//
	inline function pokeIntSigned(pos:Int, int:Int):Void poke(pos, s32, int);
	inline function pokeIntUnsigned(pos:Int, uint:Int):Void poke(pos, u32, uint);
	inline function pokeInt(pos:Int, int:Int):Void poke(pos, s32, int);
	//
	inline function pokeFloat(pos:Int, float:Float):Void poke(pos, f32, float);
	inline function pokeDouble(pos:Int, double:Float):Void poke(pos, f64, double);
	//
	inline function pokeString(pos:Int, str:String):Void poke(pos, string, str);
	inline function pokeChars(pos:Int, chars:String):Void poke(pos, text, chars);
	//}
	
	public function compress(offset:Int, length:Int):Buffer;
	public function decompress():Buffer;
	
	/// Synchronously loads a buffer from given file.
	public static function load(path:String):Buffer;
	
	///
	public function save(path:String):Void;
	
	/// 
	@:native("save_ext") public function savePart(path:String, offset:Int, size:Int):Void;
	
	/// Computes an MD5 hash of given buffer fragment.
	public function md5(offset:Int, size:Int):String;
	
	public function sha1(offset:Int, size:Int):String;
}
@:std private class BufferImpl {
	public static function writeBuffer(dst:Buffer, src:Buffer):Bool {
		var dstPos = dst.position;
		var srcLen = src.length;
		var dstNext = dstPos + srcLen;
		var dstSize = dst.size;
		if (dstNext > dstSize) {
			if (dst.kind == BufferKind.Grow) {
				do {
					dstSize *= 2;
				} while (dstNext > dstSize);
				dst.resize(dstSize);
			} else return false;
		}
		dst.copyFrom(dstPos, src, 0, srcLen);
		dst.position = dstNext;
		return true;
	}
	public static function writeBufferExt(dst:Buffer, src:Buffer, srcPos:Int, srcLen:Int):Bool {
		var dstPos = dst.position;
		var dstNext = dstPos + srcLen;
		var dstSize = dst.size;
		if (dstNext > dstSize) {
			if (dst.kind == BufferKind.Grow) {
				do {
					dstSize *= 2;
				} while (dstNext > dstSize);
				dst.resize(dstSize);
			} else return false;
		}
		dst.copyFrom(dstPos, src, srcPos, srcLen);
		dst.position = dstNext;
		return true;
	}
}
