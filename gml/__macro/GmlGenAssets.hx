package gml.__macro;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import gml.assets.AssetType;
import sf.gml.SfGmx;
import haxe.Json;
import haxe.CallStack;
using haxe.io.Path;

/**
 * ...
 * @author YellowAfterlife
 */
class GmlGenAssets {
	static function indexGmx(path:String, pairs:Array<GmlGenAssetsPair>) {
		var gmx = SfGmx.parse(File.getContent(path));
		function addAssets(one:String, type:AssetType) {
			for (items in gmx.findAll(one + "s")) {
				for (item in items.findRec(one)) {
					pairs.push({ name: GmlGenTools.nameOf(item.text), type: type });
				}
			}
		}
		addAssets("sprite",     AssetType.ASprite);
		addAssets("background", AssetType.ABackground);
		addAssets("sound",      AssetType.ASound);
		addAssets("path",       AssetType.APath);
		addAssets("font",       AssetType.AFont);
		addAssets("shader",     AssetType.AShader);
		addAssets("timeline",   AssetType.ATimeline);
		addAssets("script",     AssetType.AScript);
		addAssets("object",     AssetType.AObject);
		addAssets("room",       AssetType.ARoom);
	}
	static function indexYyp(path:String, pairs:Array<GmlGenAssetsPair>) {
		var yy = Json.parse(File.getContent(path));
		var resources:Array<Dynamic> = yy.resources;
		for (pair in resources) {
			var item:Dynamic = pair.Value;
			inline function addAsset(type:AssetType) {
				pairs.push({ name: GmlGenTools.nameOf(item.resourcePath), type: type });
			}
			switch (item.resourceType) {
				case "GMSprite":   addAsset(AssetType.ASprite);
				case "GMSound":    addAsset(AssetType.ASound);
				case "GMPath":     addAsset(AssetType.APath);
				case "GMFont":     addAsset(AssetType.AFont);
				case "GMScript":   addAsset(AssetType.AScript);
				case "GMShader":   addAsset(AssetType.AShader);
				case "GMTimeline": addAsset(AssetType.ATimeline);
				case "GMObject":   addAsset(AssetType.AObject);
				case "GMRoom":     addAsset(AssetType.ARoom);
			}
		}
	}
	public static macro function build(?path:String):Array<Field> {
		if (path == null) path = GmlGenTools.projectPath();
		if (path == null) return null;
		var pos = Context.currentPos();
		if (!FileSystem.exists(path)) {
			Context.warning('GmlGenAssets: $path does not exist.', pos);
			return null;
		}
		var cachePath = path + ".sfgml-assets-cache";
		var cacheGen:Bool = true;
		var projectTime = FileSystem.stat(path).mtime.getTime();
		var pairs:Array<GmlGenAssetsPair> = [];
		//
		if (FileSystem.exists(cachePath)) {
			var input = File.read(cachePath);
			var cacheTime = input.readDouble();
			if (cacheTime >= projectTime) try {
				var count = input.readInt32();
				for (i in 0 ... count) {
					var nameLen = input.readByte();
					var name = input.readString(nameLen);
					var type = input.readByte();
					pairs.push({ name: name, type: type });
				}
				cacheGen = false;
			} catch (e:Dynamic) {
				Sys.println("Error reading asset cache: " + e
					+ " " + CallStack.toString(CallStack.exceptionStack()));
				Sys.println("Position: " + input.tell());
				input.seek(0, SeekEnd);
				var eofAt = input.tell();
				Sys.println("Length: " + eofAt);
				pairs = [];
			}
		}
		//
		if (cacheGen) {
			Sys.println("GmlGenAssets: regenerating cache...");
			var output = File.write(cachePath);
			output.writeDouble(projectTime);
			var ext = path.extension().toLowerCase();
			switch (ext) {
				case "gmx": indexGmx(path, pairs);
				case "yyp": indexYyp(path, pairs);
				default: {
					Context.warning('GmlGenAssets: .$ext is not a known project type.', pos);
					return null;
				};
			}
			output.writeInt32(pairs.length);
			for (pair in pairs) {
				var name:String = pair.name;
				var len = name.length;
				if (len > 255) { len = 255; name = name.substring(0, len); }
				output.writeByte(len);
				output.writeString(name);
				output.writeByte(pair.type);
			}
			output.close();
		}
		//
		var fields = Context.getBuildFields();
		var i = fields.length;
		while (--i >= 0) switch (fields[i].name) {
			case "macroNotLoaded", "macroLoading": {
				fields.splice(i, 1);
				break;
			};
			default:
		}
		//
		for (pair in pairs) {
			var type = GmlGenTools.assetTypeToComplexType(pair.type);
			var meta:Metadata = pair.type == AScript ? [{ name: ":script", pos: pos }] : null;
			fields.push({
				name: pair.name, pos: pos,
				kind: FProp("default", "never", type),
				access: [APublic, AStatic],
				meta: meta
			});
		}
		//
		return fields;
	}
}
private typedef GmlGenAssetsPair = { name:String, type:AssetType };
