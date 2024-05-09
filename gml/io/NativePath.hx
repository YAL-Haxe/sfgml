package gml.io;

@:native("filename") @:snakeCase
@:std extern class NativePath {
	@:native("name") static function withoutDirectory(path:String):String;
	@:native("dir") static function directory(path:String):String;
	
	/** "file.png" -> ".png", "file" -> "" */
	@:native("ext")
	static function extension(path:String):String;
	
	@:native("change_ext")
	static function withExtension(path:String, newExt:String):String;
	
	static inline function withoutExtension(path:String):String {
		return withExtension(path, "");
	}
}