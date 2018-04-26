package haxe.io;
import gml.io.Buffer;
import gml.io.BufferKind;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
class BytesInput extends Input {
	
	public var position(get, set):Int;
	private inline function get_position():Int {
		return dataPos;
	}
	private inline function set_position(p:Int):Int {
		dataPos = p;
		return p;
	}
	
	public var length(get, never):Int;
	private inline function get_length():Int {
		return dataLen;
	}
	
	public function new(sourceBytes:Bytes, sourcePos:Int = 0, ?sourceLen:Int) {
		if (sourceLen == null) sourceLen = sourceBytes.length - sourcePos;
		this.data = sourceBytes.getData();
		this.dataPos = sourcePos;
		this.dataLen = sourceLen;
	}
}
#else
class BytesInput extends Input {
	//
	public var position(get, set):Int;
	private inline function get_position():Int return buf.tell();
	private inline function set_position(p:Int):Int { buf.seek(Start, p); return p; }
	//
	public var length(get, never):Int;
	private inline function get_length():Int return buf.size;
	//
	public inline function new(sourceBytes:Bytes, sourcePos:Int = 0, ?sourceLen:Int) {
		if (sourceLen == null) sourceLen = sourceBytes.length - sourcePos;
		buf = new Buffer(sourceLen, BufferKind.Fixed, 1);
		buf.copyFrom(0, sourceBytes.getData(), sourcePos, sourceLen);
	}
}
#end
