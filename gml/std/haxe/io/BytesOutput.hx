package haxe.io;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
#if !sfgml_native_bytes
@:std class BytesOutput extends Output {
	
	public var length(get, never):Int;
	private inline function get_length():Int {
		return dataPos;
	}
	
	public function new() {
		//
	}
	
	public inline function getBytes():Bytes {
		return Bytes.ofData(data);
	}
}
#else
@:std class BytesOutput extends Output {
	
	public var length(get, never):Int;
	private inline function get_length():Int {
		return buf.position;
	}
	
	public inline function new() {
		buf = new Buffer(1024, Grow, 1);
	}
	
	public inline function getBytes():Bytes {
		return Bytes.ofData(buf);
	}
	
	override public function close() {
		// don't dealloc because that's what we return in getBytes
	}
}
#end
