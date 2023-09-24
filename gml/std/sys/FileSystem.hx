package sys;
import SfTools.raw;
import gml.io.NativeFileSystem;

/**
 * ...
 * @author YellowAfterlife
 */
#if !macro
@:native("haxe.filesys") @:std
#end
class FileSystem {
	public static function exists(path:String):Bool {
		return NativeFileSystem.exists(path) || NativeFileSystem.isDirectory(path);
	}
	public static inline function rename(oldPath:String, newPath:String):Void {
		NativeFileSystem.rename(oldPath, newPath);
	}
	public static inline function copy(oldPath:String, newPath:String):Void {
		NativeFileSystem.copy(oldPath, newPath);
	}
	
	public static inline function isDirectory(path:String) {
		return NativeFileSystem.isDirectory(path);
	}
	public static inline function createDirectory(path:String):Void {
		NativeFileSystem.createDirectory(path);
	}
	
	public static inline function deleteFile(path:String):Bool {
		NativeFileSystem.deleteFile(path);
		return true;
	}
	
	public static inline function deleteDirectory(path:String):Void {
		NativeFileSystem.deleteDirectory(path);
	}
	
	@:native("find_all")
	public static function readDirectory(path:String):Array<String> {
		switch (gml.NativeString.charCodeAt(path, gml.NativeString.length(path))) {
			case "/".code, "\\".code: { };
			default: path += "/";
		}
		var attrs = gml.Syntax.code("fa_readonly|fa_hidden|fa_directory");
		var next = NativeFileSystem.findFirst(path + "*.*", attrs);
		var out:Array<String> = [];
		var found:Int = 0;
		while (next != "") {
			out[found] = next;
			found += 1;
			next = NativeFileSystem.findNext();
		}
		NativeFileSystem.findClose();
		return out;
	}
}
