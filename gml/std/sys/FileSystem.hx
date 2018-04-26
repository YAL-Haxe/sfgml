package sys;
import SfTools.raw;

/**
 * ...
 * @author YellowAfterlife
 */
#if !macro @:native("file") #end
class FileSystem {
	
	@:remove public static function exists(path:String):Bool {
		return raw("file_exists")(path);
	}
	
	@:remove public static function rename(path:String, next:String):Void {
		raw("file_rename")(path, next);
	}
	
	@:extern public static inline function isDirectory(path:String):Bool {
		return raw("directory_exists")(path);
	}
	
	@:extern public static inline function createDirectory(path:String):Void {
		raw("directory_create")(path);
	}
	
	@:extern public static inline function deleteFile(path:String):Bool {
		return raw("file_delete")(path);
	}
	
	@:extern public static inline function deleteDirectory(path:String):Void {
		raw("directory_destroy")(path);
	}
	
	@:native("find_all")
	public static function readDirectory(path:String):Array<String> {
		switch (gml.NativeString.charCodeAt(path, gml.NativeString.length(path))) {
			case "/".code, "\\".code: { };
			default: path += "/";
		}
		var next:String = raw("file_find_first")(path + "*.*", raw("fa_readonly|fa_hidden|fa_directory"));
		var out:Array<String> = [];
		var found:Int = 0;
		while (next != "") {
			out[found] = next;
			found += 1;
			next = raw("file_find_next")();
		}
		raw("file_find_close")();
		return out;
	}
}
