package sf;
import haxe.Json;
import haxe.io.Path;
import haxe.macro.Context;
import sf.opt.syntax.SfGmlRest;
import sf.type.SfClass;
import sf.type.SfClassField;
import sf.type.SfField;
import sys.FileSystem;
import sys.io.File;
import sf.SfCore.sfConfig;
import sf.SfCore.sfGenerator;
import sf.gml.SfYyExtension;
import sf.gml.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfYyGen {
	private static function error(text:String, path:String) {
		#if macro
		Context.error(text, Context.makePosition({ file: path, min: 0, max: 0 }));
		#else
		throw text;
		#end
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
	static var getText_path:String = null;
	static var getText_text:String = null;
	public static function getText(path:String) {
		if (path == getText_path && getText_text != null) return getText_text;
		var path_in = path;
		if (/*!FileSystem.exists(path) && */FileSystem.exists(path + ".base")) {
			path_in += ".base";
		}
		var text:String = File.getContent(path_in);
		getText_path = path;
		getText_text = text;
		return text;
	}
	static function findExtFile(extension:SfYyExtension, path:String):SfYyExtFile {
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
	}
	static function runV22(path:String, json:String) {
		// GMS2 uses non-spec int64s in extensions JSON
		json = ~/("(?:copyToTargets|supportedTargets)":\s*)(\d{12,32})/g.replace(json, '$1"$2"');
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
		var file:SfYyExtFile = findExtFile(extension, path);
		//
		var gd:Bool = sfConfig.gmxDoc;
		var md:Bool = sfConfig.gmxMcrDoc;
		var skipFuncs = sfConfig.codePath != null;
		var canHide = true;
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
		sfGenerator.printTo(Path.directory(path) + "/" + file.filename);
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
				hidden: canHide && doc == null
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
				// https://bugs.yoyogames.com/view.php?id=30523
				help: (gd && doc != null) ? doc : (canHide ? "" : name + "(...)"),
				hidden: canHide && !(gd && doc != null),
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
		json = SfYyJson.stringify(extension);
		timeEnd();
		//
		//println("Postfixing flags...");
		json = ~/("(?:copyToTargets|supportedTargets)":\s*)"([^"]+)"/g.replace(json, '$1$2');
		//
		timeStart("Saving");
		File.saveContent(path, json);
		timeEnd();
	}
	static function runV23(path:String, json:String) {
		var timeShow = true, timeStamp = 0.;
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
		var extension:SfYyExtension = SfYyJson.parse(json, true);
		timeEnd();
		//
		var funcDoc = sfConfig.gmxDoc;
		var macroDoc = sfConfig.gmxMcrDoc;
		var skipFuncs = sfConfig.codePath != null;
		//
		var file:SfYyExtFile = findExtFile(extension, path);
		var mcrArr = file.constants;
		mcrArr.resize(0);
		var fnArr = file.functions;
		fnArr.resize(0);
		//
		timeStart("Printing GML");
		sfGenerator.printTo(Path.directory(path) + "/" + file.filename);
		timeEnd();
		//
		function addMacro(name:String, value:String, doc:String) {
			mcrArr.push({
				value: value,
				hidden: doc == null,
				resourceVersion: "1.0",
				name: name,
				tags: [],
				resourceType: "GMExtensionConstant"
			});
		}
		function addFunc(name:String, doc:String, fd:SfField) {
			if (skipFuncs) return;
			
			var argc = fd.args != null ? fd.args.length : 0;
			if (argc > 0) {
				var lastArg = fd.args[argc - 1];
				if (lastArg.value != null // has optional arguments
					|| SfGmlRest.getRestType(lastArg.v.type) != null // has rest-arg
				) {
					argc = -1; // allow any number of arguments (for lack of better options)
				}
			}
			
			if (Std.is(fd, SfClassField)) {
				var cf:SfClassField = cast fd;
				
				// add a spot for `this` argument in linear functions
				if (argc >= 0 && cf.needsThisArg()) argc += 1;
			}
			
			var argTypes = [];
			for (i in 0 ... argc) argTypes.push(2);
			
			fnArr.push({
				name: name,
				externalName: name,
				help: funcDoc && doc != null ? doc : "",
				hidden: !(funcDoc && doc != null),
				kind: 2,
				returnType: 2,
				argCount: argc,
				args: argTypes,
				resourceVersion: "1.0",
				tags: [],
				resourceType: "GMExtensionFunction",
			});
		}
		//
		if (!skipFuncs && sfConfig.entrypoint != "") {
			var ep = sfConfig.entrypoint;
			fnArr.push({
				name: ep,
				externalName: ep,
				help: "",
				hidden: true,
				kind: 2,
				returnType: 2,
				argCount: 0,
				args: [],
				resourceVersion: "1.0",
				tags: [],
				resourceType: "GMExtensionFunction",
			});
		}
		SfGmxGen.iter(addFunc, addMacro);
		//
		timeStart("Encoding JSON");
		json = SfYyJsonPrinter.stringify(extension, true);
		timeEnd();
		//
		json = ~/("(?:copyToTargets|supportedTargets)":\s*)"([^"]+)"/g.replace(json, '$1$2');
		//
		timeStart("Saving");
		File.saveContent(path, json);
		timeEnd();
	}
	public static function run(path:String) {
		var json = getText(path);
		if (json.indexOf('"resourceType":') >= 0) {
			runV23(path, json);
		} else {
			runV22(path, json);
		}
		
	}
}
