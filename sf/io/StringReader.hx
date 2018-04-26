package sf.io;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("string_reader")
class StringReader {
	//
	private var source:Buffer;
	public var pos:Int;
	public var length(default, null):Int;
	//
	public var loop(get, never):Bool;
	private inline function get_loop():Bool return (pos < length);
	//
	public inline function tell():Int return pos;
	public inline function seek(p:Int):Void pos = p;
	//
	private static function buf(s:String):Buffer {
		var len = gml.NativeString.byteLength(s);
		var sb = new Buffer(len, Fixed, 1);
		sb.writeChars(s);
		var fb = new Buffer(len, Fast, 1);
		fb.copyFrom(0, sb, 0, len);
		sb.destroy();
		return fb;
	}
	private static function sub(b:Buffer, start:Int, till:Int):String {
		var len = till - start;
		if (len <= 0) return "";
		var sb = new Buffer(len, Fixed, 1);
		sb.copyFrom(0, b, start, len);
		var r = sb.readString();
		sb.destroy();
		return r;
	}
	//
	public inline function new(src:String) {
		source = buf(src);
		length = source.length;
		pos = 0;
	}
	public inline function close() { }
	//
	public inline function read():Int return source.peekByte(pos++);
	public inline function peek():Int return source.peekByte(pos);
	public inline function get(p:Int):Int return source.peekByte(p);
	public inline function skip():Void pos += 1;
	
	public inline function substring(start:Int, till:Int):String {
		return sub(source, start, till);
	}
}
