package sf;
import haxe.Json;
import haxe.io.Path;
import haxe.macro.Context;
import sf.type.SfClass;
import sf.type.SfClassField;
import sf.type.SfField;
import sys.FileSystem;
import sys.io.File;
import sf.SfCore.sfConfig;
import sf.SfCore.sfGenerator;
import sf.gml.SfYyExtension;

/**
 * ...
 * @author YellowAfterlife
 */
class SfYyGen {
	private static function error(text:String, path:String) {
		#if macro
		Context.error(text, Context.makePosition({ file: path, min: 0, max: 0 }));
		#end
		throw text;
	}
	private static function print(text:String) {
		#if sys
		Sys.print(text);
		#else
		trace(text);
		#end
	}
	private static function println(text:String) {
		#if sys
		Sys.println(text);
		#else
		trace(text);
		#end
	}
	public static function run(path:String) {
		var path_in = path;
		if (!FileSystem.exists(path) && FileSystem.exists(path + ".base")) path_in += ".base";
		var json:String = File.getContent(path_in);
		// GMS2 uses non-spec int64s in extensions JSON
		json = ~/("copyToTargets":\s*)(\d{12,32})/g.replace(json, '$1"$2"');
		//
		var timeShow = false, timeStamp = 0.;
		inline function timeStart(name:String) {
			if (timeShow) {
				print(name + "...");
				timeStamp = Sys.time();
			}
		}
		inline function timeEnd() {
			if (timeShow) println(' OK! (' + Std.int((Sys.time() - timeStamp) * 1000) + 'ms)');
		}
		//
		timeStart("Decoding JSON");
		var extension:SfYyExtension = Json.parse(json);
		timeEnd();
		//
		var file:SfYyExtFile = (function() {
			var fileName:String = sfConfig.gmxFile;
			var file:SfYyExtFile;
			if (fileName != null) {
				for (q in extension.files) {
					if (q.filename == fileName) {
						file = q; break;
					}
				}
				if (file == null) error('Extension does not have a file `$fileName`.', path);
			} else {
				for (q in extension.files) {
					if (Path.extension(q.filename).toLowerCase() == "gml") {
						file = q; break;
					}
				}
				if (file == null) error("Extension has no GML files.", path);
			}
			return file;
		})();
		//
		var gd:Bool = sfConfig.gmxDoc;
		var md:Bool = sfConfig.gmxMcrDoc;
		var skipFuncs = sfConfig.codePath != null;
		var debug = sfConfig.debug;
		//
		var mArr = file.constants;
		var mMap = new Map<String, SfYyGUID>();
		for (q in mArr) mMap.set(q.constantName, q.id);
		mArr = []; file.constants = mArr;
		//
		var fArr = file.functions;
		var fMap = new Map<String, SfYyGUID>();
		for (q in fArr) fMap.set(q.name, q.id);
		fArr = []; if (!skipFuncs) file.functions = fArr;
		//
		timeStart("Printing GML");
		if (sfConfig.codePath == null) {
			var filePath:String = Path.directory(path) + "/" + file.filename;
			sfGenerator.printTo(filePath);
		} else sfGenerator.printTo(sfConfig.codePath);
		timeEnd();
		//
		function addMacro(name:String, value:String, doc:String) {
			var id = mMap.get(name);
			if (id == null) id = new SfYyGUID();
			mArr.push({
				id: id,
				modelName: "GMExtensionConstant",
				mvc: "1.0",
				constantName: name,
				value: value,
				hidden: !debug && doc == null
			});
		}
		function addFunc(name:String, doc:String, sff:SfField) {
			if (skipFuncs) return;
			var argc:Int = sff.args != null ? sff.args.length : 0;
			if (argc > 0) {
				var last = sff.args[argc - 1];
				switch (last.v.type) {
					case TAbstract(_.get() => { name: "SfRest" }, _): argc = -1;
					default: if (last.value != null) argc = -1;
				}
			}
			if (argc >= 0 && Std.is(sff, SfClassField)) {
				var sfcf:SfClassField = cast sff;
				if (sfcf.isInst) argc += 1;
			}
			if (!(gd && doc != null)) argc = -1;
			var args:Array<Int> = [];
			for (i in 0 ... argc) args.push(2);
			var id = fMap.get(name);
			if (id == null) id = new SfYyGUID();
			fArr.push({
				id: id,
				modelName: "GMExtensionFunction",
				mvc: "1.0",
				name: name,
				externalName: name,
				help: gd && doc != null ? doc : "",
				hidden: !debug && !(gd && doc != null),
				kind: 2,
				returnType: 2,
				argCount: argc,
				args: args,
			});
		}
		//
		if (!skipFuncs && sfConfig.entrypoint != "") {
			var ep = sfConfig.entrypoint;
			var id = fMap.get(ep);
			if (id == null) id = new SfYyGUID();
			fArr.push({
				id: id,
				modelName: "GMExtensionFunction",
				mvc: "1.0",
				name: ep,
				externalName: ep,
				help: "",
				hidden: true,
				kind: 2,
				returnType: 2,
				argCount: 0,
				args: [],
			});
		}
		SfGmxGen.iter(addFunc, addMacro);
		//
		timeStart("Encoding JSON");
		json = Json.stringify(extension, null, "    ");
		timeEnd();
		//
		//println("Postfixing linebreaks...");
		//json = StringTools.replace(json, "\n", "\r\n");
		//json = ~/\n/g.replace(json, "\r\n");
		//
		//println("Postfixing flags...");
		json = ~/("copyToTargets":\s*)"([^"]+)"/g.replace(json, '$1$2');
		//
		timeStart("Saving");
		File.saveContent(path, json);
		timeEnd();
	}
}
