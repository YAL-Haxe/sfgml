package gml.io;
import gml.io.Buffer;
/**
 * ...
 * @author YellowAfterlife
 */
@:forward(size, position, shiftPosition, destroy, rewind, read, peek,
	readBool, readByteSigned, readByteUnsigned,
	readShortSigned, readShortUnsigned, readIntSigned, readIntUnsigned,
	readFloat, readDouble, readString,
	peekBool, peekByteSigned, peekByteUnsigned,
	peekShortSigned, peekShortUnsigned, peekIntSigned, peekIntUnsigned,
	peekFloat, peekDouble, peekString)
abstract BufferReader(Buffer) from Buffer to Buffer {
	public inline function new(size:Int, kind:BufferKind, alignment:Int) {
		this = new Buffer(size, kind, alignment);
	}
}