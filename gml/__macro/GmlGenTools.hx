package gml.__macro;
import gml.assets.AssetType;
import haxe.io.*;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
using haxe.io.Path;

/**
 * ...
 * @author YellowAfterlife
 */
class GmlGenTools {
	
	/** Reads a string prefixed with a single-byte length */
	public static function readString1(input:Input) {
		var n = input.readByte();
		return n != 0xff ? input.readString(n) : null;
	}
	
	/** Reads a string prefixed with two-byte length */
	public static function readString2(input:Input) {
		var n = input.readUInt16();
		return n != 0xffff ? input.readString(n) : null;
	}
	
	public static function writeString1(output:Output, s:String) {
		if (s != null) {
			var b = Bytes.ofString(s);
			var n = b.length;
			if (n > 0xfe) n = 0xfe;
			output.writeByte(n);
			output.writeFullBytes(b, 0, n);
		} else output.writeByte(0xff);
	}
	
	public static function writeString2(output:Output, s:String) {
		if (s != null) {
			var b = Bytes.ofString(s);
			var n = b.length;
			if (n > 0xfffe) n = 0xfffe;
			output.writeUInt16(n);
			output.writeFullBytes(b, 0, n);
		} else output.writeUInt16(0xffff);
	}
	
	public static function nameOf(path:String) {
		return Path.withoutExtension(Path.withoutDirectory(path));
	}
	
	/** "some.project.gmx" -> "project" */
	static function gmxExt(path:String) {
		if (path.extension().toLowerCase() == "gmx") {
			return path.withoutExtension().extension().toLowerCase();
		} else return null;
	}
	
	public static function projectPath() {
		// unfortunately, haxe.macro.Compiler.getOutput() returns "Nothing__"
		// while macros is being evaluated for auto-completion, so let's have
		// a compiler parameter for now I guess
		return Context.definedValue("sfgml-assets-path");
	}
	
	private static function projectPath_1() {
		var path:String = haxe.macro.Compiler.getOutput();
		if (path.extension() == "_") path = path.withoutExtension();
		var out:String = null;
		switch (path.extension().toLowerCase()) {
			case "yy": { // .../project/extensions/extName/extName.yy
				path = path.directory(); // .../project/extensions/extName
				path = path.directory(); // .../project/extensions
				path = path.directory(); // .../project
				for (rel in FileSystem.readDirectory(path)) {
					if (rel.extension().toLowerCase() == "yyp") out = Path.join([path, rel]);
				}
			};
			case "gmx": {
				switch (gmxExt(path)) {
					case "project": out = path;
					case "extension": { // .../project/extensions/extName.extension.gmx
						path = path.directory(); // .../project/extensions
						path = path.directory(); // .../project
						for (rel in FileSystem.readDirectory(path)) {
							if (gmxExt(rel) == "project") out = Path.join([path, rel]);
						}
					};
				}
			};
			case "gml": {
				var steps = 2;
				#if (sfgml_next)
				steps = 3;
				#end
				while (--steps >= 0) {
					path = path.directory();
					for (rel in FileSystem.readDirectory(path)) {
						#if (sfgml_next)
						if (rel.extension().toLowerCase() == "yyp") out = Path.join([path, rel]);
						#else
						if (gmxExt(rel) == "project") out = Path.join([path, rel]);
						#end
					}
					if (out != null) break;
				}
			};
		}
		return out;
	}
	
	/**
	   Parses a type name string to a ComplexType, defaulting to Dynamic.
	   Ideally should allow specifying custom types, but is mostly only used in externs.
	**/
	public static function parseType(t:String, p:String):ComplexType {
		if (t == null) return macro:Dynamic;
		var tp = p != null ? parseType(p, null) : macro:Dynamic;
		return switch (t.toLowerCase()) {
			case "bool": macro:Bool;
			case "string": macro:String;
			case "int": macro:Int;
			case "real", "float", "number": macro:Float;
			case "array": return macro:Array<$tp>;
			case "inst", "instance": macro:gml.Instance;
			case "sprite": macro:gml.assets.Sprite;
			case "func": macro:haxe.Constraints.Function;
			case "background": macro:gml.assets.Background;
			case "sound": macro:gml.assets.Sound;
			case "path": macro:gml.assets.PointPath;
			case "script": macro:gml.assets.Script;
			case "shader": macro:gml.assets.Shader;
			case "font": macro:gml.assets.Font;
			case "timeline": macro:gml.assets.Timeline;
			case "object": macro:gml.assets.Object;
			case "room": macro:gml.assets.Room;
			case "void": macro:Void;
			default: macro:Dynamic;
		}
	}
	
	public static function assetTypeToComplexType(t:AssetType) {
		return switch (t) {
			case AObject:     macro:gml.assets.Object;
			case ASprite:     macro:gml.assets.Sprite;
			case ASound:      macro:gml.assets.Sound;
			case ARoom:       macro:gml.assets.Room;
			case ABackground: macro:gml.assets.Background;
			case APath:       macro:gml.assets.PointPath;
			case AScript:     macro:gml.assets.Script;
			case AFont:       macro:gml.assets.Font;
			case ATimeline:   macro:gml.assets.Timeline;
			case AShader:     macro:gml.assets.Shader;
			default:          macro:Dynamic;
		}
	}
}
