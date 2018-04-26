package gml.__macro;
import haxe.io.Input;
import haxe.io.Output;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import gml.assets.AssetType;
import sf.gml.SfGmx;
import haxe.Json;
import haxe.CallStack;
using haxe.io.Path;
using gml.__macro.GmlGenTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GmlGenScripts {
	
	private static function readType(input:Input):GmlGenScriptsType {
		var name = input.readString1();
		var params = [];
		for (i in 0 ... input.readByte()) params.push(input.readString1());
		return { name: name, params: params };
	}
	private static function writeType(output:Output, type:GmlGenScriptsType) {
		if (type != null) {
			output.writeString1(type.name);
			var params = type.params;
			var n = params.length;
			output.writeByte(n);
			for (i in 0 ... n) {
				output.writeString1(params[i]);
			}
		} else {
			output.writeByte(0xff);
			output.writeByte(0);
		}
	}
	private static function compType(type:GmlGenScriptsType):ComplexType {
		if (type == null) return macro:Dynamic;
		return GmlGenTools.parseType(type.name, type.params[0]);
	}
	
	/** This isn't 100% reliable because it has to be as fast as possible */
	private static function buildSciptArgs(code:String):Array<GmlGenScriptsArg> {
		var args:Array<GmlGenScriptsArg> = [];
		for (i in 0 ... 16) {
			if (code.indexOf("argument" + i) >= 0) {
				args.push({ name: "arg" + i });
			} else break;
		}
		if (args.length == 0 && code.indexOf("argument[") >= 0) {
			for (i in 0 ... 16) {
				if (code.indexOf("argument[" + i + "]") >= 0) {
					args.push({ name: "arg" + i, opt: true });
				} else break;
			}
			args.push({ name: "_", rest: true });
		}
		return args;
	}
	
	private static function indexGmx(path:String, out:Array<GmlGenScriptsFunc>) {
		var gmx = SfGmx.parse(File.getContent(path));
		var pos = Context.currentPos();
		var dir = Path.directory(path);
		//                     1doc  2args  3text
		var rxDoc = ~/\/\/\/\s*(\w+(\(.*?)\)(.*))/;
		//            1name          2type          3typeParam
		var rxArg = ~/(\w+)(?:\s*:\s*(\w+)(?:\s*<\s*(\w+)\s*>\s*)?)?/;
		var rxHasRet = ~/\breturn\b/;
		//                     1type          2typeParam
		var rxRet = ~/^\s*->\s*(\w+)(?:\s*<\s*(\w+)\s*>\s*)?/;
		var rxScrName = ~/[ \t]+(\w+)/;
		for (items in gmx.findAll("scripts"))
		for (item in items.findRec("script")) {
			var scrPath = Path.join([dir, item.text]);
			if (!FileSystem.exists(scrPath)) continue;
			try {
				var code:String = File.getContent(scrPath);
				var trail = false;
				var scrName = item.text.nameOf();
				// this could have given a duplicate for the first script but there can
				// be no leading content before the first script so it's not \n#define.
				for (code in code.split("\n#define")) {
					if (trail) {
						if (rxScrName.match(code)) {
							scrName = rxScrName.matched(1);
						} else continue;
					} else trail = true;
					var args = buildSciptArgs(code);
					var hasRet = rxHasRet.match(code);
					var ret:GmlGenScriptsType = hasRet
						? { name: null, params: [] }
						: { name: "void", params: [] };
					var doc = null;
					// if there's a `///doc` comment, we parse that for clarifications:
					if (rxDoc.match(code)) {
						doc = rxDoc.matched(1);
						var argd = rxDoc.matched(2).split(",");
						var n:Int = {
							var nx = args.length;
							var nd = argd.length;
							nx < nd ? nx : nd;
						};
						for (i in 0 ... n) if (rxArg.match(argd[i])) {
							args[i].name = rxArg.matched(1);
							args[i].type = { name: rxArg.matched(2), params: [rxArg.matched(3)] };
						}
						if (hasRet && rxRet.match(rxDoc.matched(3))) {
							ret = { name: rxRet.matched(1), params: [rxRet.matched(2)] };
						}
					}
					//
					out.push({ name: scrName, args: args, doc: doc, ret: ret });
				}
			} catch (e:Dynamic) {
				Sys.println('Could not index $scrPath: ' + e + " " + CallStack.toString(CallStack.exceptionStack()));
			}
		}
	}
	private static function indexYyp(path:String, out:Array<GmlGenScriptsFunc>) {
		var yy = haxe.Json.parse(File.getContent(path));
		var resources:Array<Dynamic> = yy.resources;
		var dir = Path.directory(path);
		var pos = Context.currentPos();
		var rxArg = ~/\/\/\/\s*@(?:argument|arg|param)\s+((\S+).*)/g;
		var rxVal = ~/(\w*)(?:\s*:\s*(\w+)(?:\s*<\s*(\w+)\s*>\s*)?)?/;
		var rxDesc = ~/\/\/\/\s*@(?:description|desc)\s*(.*)/;
		var rxHasRet = ~/\breturn\b/;
		var rxReturn = ~/\/\/\/\s*@(?:ret|return)\s+((\S+).*)/;
		for (pair in resources) {
			var item:Dynamic = pair.Value;
			if (item.resourceType != "GMScript") continue;
			var scrPath = Path.join([dir, Path.withoutExtension(item.resourcePath) + ".gml"]);
			if (!FileSystem.exists(scrPath)) {
				Sys.println("Script missing: " + scrPath);
				continue;
			}
			try {
				var code = File.getContent(scrPath);
				var args = buildSciptArgs(code);
				//
				var docb = new StringBuf();
				if (rxDesc.match(code)) {
					docb.add("* ");
					docb.add(rxDesc.matched(1));
					docb.addChar("\n".code);
				}
				//
				var start = 0;
				var argIndex = 0;
				while (rxArg.matchSub(code, start)) {
					if (argIndex < args.length && rxVal.match(rxArg.matched(2))) {
						args[argIndex].name = rxVal.matched(1);
						args[argIndex].type = { name:rxVal.matched(2), params:[rxVal.matched(3)] };
					}
					docb.add("* @param\t");
					docb.add(rxArg.matched(1));
					docb.addChar("\n".code);
					//
					var rxPos = rxArg.matchedPos();
					start = rxPos.pos + rxPos.len;
					argIndex += 1;
				}
				//
				var hasRet = rxHasRet.match(code);
				var ret:GmlGenScriptsType;
				if (hasRet) {
					ret = { name: null, params: [] };
					if (rxReturn.match(code)) {
						docb.add("* @return\t");
						docb.add(rxReturn.matched(1));
						docb.addChar("\n".code);
						if (rxVal.match(rxReturn.matched(2))) {
							ret = { name:rxVal.matched(2), params:[rxVal.matched(3)] };
						}
					}
				} else ret = { name: "void", params: [] };
				//
				out.push({
					name: scrPath.nameOf(),
					doc: docb.toString(),
					args: args, ret: ret,
				});
			} catch (e:Dynamic) {
				Sys.println('Could not index $scrPath: ' + e + " "
					+ CallStack.toString(CallStack.exceptionStack()));
				return;
			}
		}
	}
	public static macro function build(?path:String):Array<Field> {
		if (path == null) path = GmlGenTools.projectPath();
		if (path == null) return null;
		var pos = Context.currentPos();
		if (!FileSystem.exists(path)) {
			Context.warning('GmlGenScripts: $path does not exist.', pos);
			return null;
		}
		//
		var cachePath = path + ".sfgml-scripts-cache";
		var cacheGen:Bool = true;
		var projectTime = FileSystem.stat(path).mtime.getTime();
		var pairs:Array<GmlGenScriptsFunc> = [];
		//
		if (FileSystem.exists(cachePath)) {
			var input = File.read(cachePath);
			var cacheTime = input.readDouble();
			if (cacheTime >= projectTime) try {
				var count = input.readInt32();
				for (i in 0 ... count) {
					var args = [];
					pairs.push({
						name: input.readString1(),
						doc: input.readString2(),
						ret: readType(input),
						args: args,
					});
					for (k in 0 ... input.readByte()) {
						var arg:GmlGenScriptsArg = {
							name: input.readString1(),
							type: readType(input),
						};
						var flags = input.readByte();
						if (flags & 1 != 0) arg.opt = true;
						if (flags & 2 != 0) arg.rest = true;
						args.push(arg);
					}
				}
				cacheGen = false;
			} catch (e:Dynamic) {
				Sys.println("Error reading script cache: " + e
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
			var t = haxe.Timer.stamp();
			Sys.print("GmlGenScripts: regenerating cache...");
			var output = File.write(cachePath);
			output.writeDouble(projectTime);
			var ext = path.extension().toLowerCase();
			switch (ext) {
				case "gmx": indexGmx(path, pairs);
				case "yyp": indexYyp(path, pairs);
				default: {
					Context.warning('GmlGenScripts: .$ext is not a known project type.', pos);
					return null;
				};
			}
			output.writeInt32(pairs.length);
			for (pair in pairs) {
				var name:String = pair.name;
				output.writeString1(pair.name);
				output.writeString2(pair.doc);
				writeType(output, pair.ret);
				var args:Array<GmlGenScriptsArg> = pair.args;
				output.writeByte(args.length);
				for (i in 0 ... args.length) {
					var arg:GmlGenScriptsArg = args[i];
					output.writeString1(arg.name);
					writeType(output, arg.type);
					var flags = 0x0;
					if (arg.opt) flags |= 0x1;
					if (arg.rest) flags |= 0x2;
					output.writeByte(flags);
				}
			}
			output.close();
			Sys.println("OK! (" + Std.int((haxe.Timer.stamp() - t) * 1000) + "ms)");
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
		for (func in pairs) {
			var args = [];
			for (arg in func.args) {
				var argt = compType(arg.type);
				if (arg.rest) argt = macro:haxe.extern.Rest<$argt>;
				args.push({
					name: arg.name,
					type: argt,
					opt: arg.opt
				});
			}
			var ret = compType(func.ret);
			fields.push({
				name: func.name,
				doc: func.doc, pos: pos,
				kind: FFun({ args: args, ret: ret, expr: null }),
				access: [APublic, AStatic],
			});
		}
		//
		return fields;
	}
}
private typedef GmlGenScriptsFunc = {
	var name:String;
	var doc:String;
	var ret:GmlGenScriptsType;
	var args:Array<GmlGenScriptsArg>;
}
private typedef GmlGenScriptsArg = {
	name:String,
	?type:GmlGenScriptsType,
	?opt:Bool,
	?rest:Bool
}
private typedef GmlGenScriptsType = {
	var name:String;
	var params:Array<String>;
};
