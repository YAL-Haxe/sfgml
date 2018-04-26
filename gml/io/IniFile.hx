package gml.io;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("ini") extern class IniFile {
	static function open(path:String):Void;
	static function close():Void;
	//
	@:native("section_delete") static function deleteSection(section:String):Void;
	@:native("key_delete") static function deleteKey(section:String, key:String):Void;
	//
	@:native("section_exists") static function hasSection(section:String):Bool;
	@:native("key_delete") static function hasKey(section:String, key:String):Bool;
	//
	@:native("read_real") static function readFloat(section:String, key:String, defValue:Float):Float;
	@:native("read_string") static function readString(section:String, key:String, defValue:String):String;
	static inline function readInt(section:String, key:String, defValue:Int):Int {
		return Math.round(readFloat(section, key, defValue));
	}
	//
	@:native("write_real") static function writeFloat(section:String, key:String, value:Float):Void;
	@:native("write_string") static function writeString(section:String, key:String, value:String):Void;
	static inline function writeInt(section:String, key:String, value:Int):Void {
		writeString(section, key, Std.string(value));
	}
	//
}
