package gml.io;

/**
 * ...
 * @author 
 */
@:native("file") @:snakeCase
@:std extern class NativeFileSystem {
	static function exists(path:String):Bool;
	@:native("delete") static function deleteFile(path:String):Void;
	static function rename(oldPath:String, newPath:String):Void;
	static function copy(oldPath:String, newPath:String):Void;
	static function attributes(path:String):Int;
	
	@:expose("directory_exists") static function isDirectory(path:String):Bool;
	@:expose("directory_create") static function createDirectory(path:String):Void;
	@:expose("directory_destroy") static function deleteDirectory(path:String):Void;
	
	static function findFirst(mask:String, attr:Int):String;
	static function findNext():String;
	static function findClose():Void;
}