package haxe.io;
import gml.io.Buffer;
import gml.io.BufferKind;

/**
 * ...
 * @author YellowAfterlife
 */
class StringInput extends Input {
	//
	public var position(get, set):Int;
	private inline function get_position():Int return buf.tell();
	private inline function set_position(p:Int):Int { buf.seek(Start, p); return p; }
	//
	public var length(get, never):Int;
	private inline function get_length():Int return buf.size;
	//
	public inline function new(s:String) {
		buf = new Buffer(gml.NativeString.byteLength(s), BufferKind.FIXED, 1);
		buf.pokeChars(0, s);
	}
}
