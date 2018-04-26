package sf.io;
import gml.io.Buffer;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("string_builder")
abstract StringBuilder(Buffer) {
	public var length(get, never):Int;
	private inline function get_length() return this.position;
	//
	public inline function new() {
		this = new Buffer(4, Grow, 1);
	}
	public inline function close() {
		this.destroy();
	}
	//
	public inline function addChar(c:Int) this.writeByte(c);
	public inline function addString(s:String) this.writeChars(s);
	public inline function addInt(i:Int) this.writeChars(Std.string(i));
	//
	@:native("print") public function toString():String {
		var p = this.position;
		this.writeByte(0);
		this.rewind();
		var s = this.readString();
		this.position = p;
		return s;
	}
}
