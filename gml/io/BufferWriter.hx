package gml.io;
import gml.io.Buffer;
/**
 * ...
 * @author YellowAfterlife
 */
@:forward(size, position, shiftPosition, destroy, rewind, resize, copyFrom, fill, write, poke,
	writeBool, writeByteSigned, writeByteUnsigned,
	writeShortSigned, writeShortUnsigned, writeIntSigned, writeIntUnsigned,
	writeFloat, writeDouble, writeString,
	pokeBool, pokeByteSigned, pokeByteUnsigned,
	pokeShortSigned, pokeShortUnsigned, pokeIntSigned, pokeIntUnsigned,
	pokeFloat, pokeDouble, pokeString)
abstract BufferWriter(Buffer) from Buffer to Buffer {
	public inline function new(size:Int, kind:BufferKind, alignment:Int) {
		this = new Buffer(size, kind, alignment);
	}
}