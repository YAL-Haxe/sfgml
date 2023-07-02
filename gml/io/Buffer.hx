package gml.io;
import gml.gpu.Surface;
import gml.gpu.VertexBuffer;
import gml.io.BufferType;
import haxe.Int64;

/**
 * GameMaker buffers are much like Flash API buffers,
 * but have to be deallocated explicitly.
 * @author YellowAfterlife
 */
@:native("buffer") @:final @:snakeCase
extern class Buffer {
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
	
	public function setUsedSize(size:Int):Void;
	
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
	inline function readInt64():Int return read(u64);
	//
	inline function readFloat():Float return read(f32);
	inline function readDouble():Float return read(f64);
	inline function readString():String return read(string);
	// extensions:
	/** NB! this takes pos, len in reverse order for some reason */
	inline function readBuffer(dst:Buffer, len:Int, dstPos:Int = 0):Int {
		return BufferImpl.readBuffer(this, dst, dstPos, len);
	}
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
	inline function writeInt64(long:Dynamic):Void write(u64, long);
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
	inline function peekIntSigned(pos:Int):Int return peek(pos, s32);
	inline function peekIntUnsigned(pos:Int):Int return peek(pos, u32);
	inline function peekInt(pos:Int):Int return peek(pos, s32);
	inline function peekInt64(pos:Int):Int64 return peek(pos, u64);
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
	inline function pokeInt64(pos:Int, long:Int64):Void poke(pos, u64, long);
	//
	inline function pokeFloat(pos:Int, float:Float):Void poke(pos, f32, float);
	inline function pokeDouble(pos:Int, double:Float):Void poke(pos, f64, double);
	//
	inline function pokeString(pos:Int, str:String):Void poke(pos, string, str);
	inline function pokeChars(pos:Int, chars:String):Void poke(pos, text, chars);
	//}
	
	public function compress(offset:Int, length:Int):Buffer;
	public function decompress():Buffer;
	
	#if !sfgml.modern
	@:native("get_surface") private function getSurfaceImpl(sf:Surface, mode:Int, offset:Int, modulo:Int):Void;
	@:native("set_surface") private function setSurfaceImpl(sf:Surface, mode:Int, offset:Int, modulo:Int):Void;
	#end
	
	#if (sfgml_version >= "2022")
	/** Copies BGRA data from a surface to a buffer */
	function getSurface(src_surface:Surface, offset:Int):Void;
	
	/** Copies BGRA data from a buffer to a surface */
	function setSurface(dst_surface:Surface, offset:Int):Void;
	#else
	/** Copies BGRA data from a surface to a buffer */
	public inline function getSurface(sf:Surface, offset:Int):Void {
		#if sfgml.modern
		return BufferImpl.getSurface(this, sf, offset);
		#else
		getSurfaceImpl(sf, 0, offset, 0);
		#end
	}
	
	/** Copies BGRA data from a buffer to a surface */
	public inline function setSurface(sf:Surface, offset:Int):Void {
		#if sfgml.modern
		return BufferImpl.setSurface(this, sf, offset);
		#else
		setSurfaceImpl(sf, 0, offset, 0);
		#end
	}
	#end
	
	/// Synchronously loads a buffer from given file.
	public static function load(path:String):Buffer;
	
	///
	public function save(path:String):Void;
	
	public function loadExt(path:String, offset:Int):Void;
	public function loadPartial(path:String, srcOffset:Int, srcLen:Int, destOffset:Int):Void;
	
	/// 
	@:native("save_ext") public function savePart(path:String, offset:Int, size:Int):Void;
	
	/// Computes an MD5 hash of given buffer fragment.
	public function md5(offset:Int, size:Int):String;
	
	public function sha1(offset:Int, size:Int):String;
	
	/** >= 2.3 */
	public function crc32(offset:Int, size:Int):Int;
	
	@:native("base64_decode") public static function fromBase64(b64:String):Buffer;
	
	@:native("base64_encode") public function toBase64():String;
	
	@:native("create_from_vertex_buffer")
	static function fromVertexBuffer(vb:VertexBuffer, type:BufferKind, alignment:Int):Buffer;
	
	@:native("create_from_vertex_buffer_ext")
	static function fromVertexBufferExt(vb:VertexBuffer, type:BufferKind, alignment:Int, startVert:Int, numVerts:Int):Buffer;
	
	inline function copyFromVertexBuffer(vb:VertexBuffer, startVertex:Int, vertexCount:Int, destOffset:Int):Void {
		vb.copyToBuffer(startVertex, vertexCount, this, destOffset);
	}
}
@:std private class BufferImpl {
	public static function readBuffer(src:Buffer, dst:Buffer, dstPos:Int, len:Int):Int {
		var srcPos = src.position;
		var srcLen = Mathf.min(len, src.length - srcPos);
		var dstLen = Mathf.min(srcLen, dst.length - dstPos);
		if (srcLen < 0) return 0;
		if (dstLen < 0) {
			src.shiftPosition(srcLen);
			return 0;
		}
		dst.copyFrom(dstPos, src, srcPos, dstLen);
		src.shiftPosition(srcLen);
		return dstLen;
	}
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
	#if sfgml.modern
	/**
	 * What's going on here:
	 * 2.3.1+ removed the long-unused mode/modulo arguments from
	 * buffer_get_surface and buffer_set_surface, but 
	 */
	static function bufferSurfaceFunctionsHave3args_init():Bool {
		var rt = Lib.runtimeVersion;
		if (NativeString.pos("2.3.0.", rt) == 1) return false;
		if (NativeString.pos("23.1.1.", rt) != 1) return true;
		var buildStr = NativeString.delete(rt, 1, "23.1.1.".length);
		if (NativeString.digits(buildStr) != buildStr) return true;
		var buildNum = NativeType.toReal(buildStr);
		return buildNum >= 186;
	}
	static var bufferSurfaceFunctionsHave3args:Bool = bufferSurfaceFunctionsHave3args_init();
	//
	static function getSetSurface_init(fn:Dynamic) {
		var ctx = { fn: fn };
		if (bufferSurfaceFunctionsHave3args) {
			return NativeFunction.bind(ctx, function(buf, surf, offset) {
				(cast NativeScope.self).fn(buf, surf, offset);
			});
		} else {
			return NativeFunction.bind(ctx, function(buf, surf, offset) {
				(cast NativeScope.self).fn(buf, surf, 0, offset, 0);
			});
		}
	}
	public static var getSurface:(buf:Buffer, surf:Surface, offset:Int)->Void = getSetSurface_init(
		NativeFunction.bind(null, Syntax.code("buffer_get_surface"))
	);
	public static var setSurface:(buf:Buffer, surf:Surface, offset:Int)->Void = getSetSurface_init(
		NativeFunction.bind(null, Syntax.code("buffer_set_surface"))
	);
	#end
}
