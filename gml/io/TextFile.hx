package gml.io;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("file_text")
extern class TextFile {
	public static inline var none:TextFile = cast -1;
	@:native("open_from_string") public function new(text:String);
	//
	@:native("open_read") public static function read(path:String):TextFile;
	@:native("open_write") public static function write(path:String):TextFile;
	@:native("open_append") public static function append(path:String):TextFile;
	public function close():Void;
	//
	public function eof():Bool;
	public function eoln():Bool;
	//
	@:native("read_real") public function readFloat():Float;
	@:native("read_string") public function readString():String;
	@:native("readln") public function readLine():String;
	//
	@:native("write_real") public function writeFloat(f:Float):Void;
	@:native("write_string") public function writeString(s:String):Void;
	@:native("writeln") public function writeLine():Void;
	//
}
