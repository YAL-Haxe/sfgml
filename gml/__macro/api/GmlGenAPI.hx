package;
#if gmlgenapi
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
@:noCompletion
class GmlGenAPI {
	
	static function each(r:EReg, s:String, f:EReg->Void) {
		var i:Int = 0;
		while (r.matchSub(s, i)) {
			f(r);
			var p = r.matchedPos();
			i = p.pos + p.len;
		}
	}
	
	static function mapType(t:String) {
		if (t == null) return "Dynamic";
		switch (t.toLowerCase()) {
			case "int": return "Int";
			case "number", "real", "float": return "Float";
			case "string": return "String";
			default: return "Dynamic";
		}
	}
	
	static function proc(v2:Bool) {
		var vi = v2 ? 2 : 1;
		var rawPath = "api/" + (v2 ? "fnames" : "fnames14");
		if (!FileSystem.exists(rawPath)) {
			Sys.println('"$rawPath" doesn\'t exist!');
			return;
		}
		var raw = File.getContent(rawPath);
		raw = ~/\r\n/g.replace(raw, "\n");
		//
		var repl = File.getContent('api/repl.gml');
		var replVer = 'api/repl$vi.gml';
		if (FileSystem.exists(replVer)) {
			repl += "\n" + File.getContent(replVer);
		}
		repl = ~/\r\n/g.replace(repl, "\n");
		each(~/^:?(\w+).+$/gm, repl, function(rx:EReg) {
			var name = rx.matched(1);
			var code = rx.matched(0);
			var found = false;
			raw = (new EReg('^$name\\b.*' + "$", "gm")).map(raw, function(r1) {
				if (!found) {
					found = true;
					return code;
				} else return r1.matched(0);
			});
		});
		//
		var className = "GmlAPI" + vi;
		var out = new StringBuf();
		out.add('package gml.__macro;\r\n');
		out.add('\r\n');
		out.add('import gml.assets.*;\r\n');
		out.add('import haxe.extern.Rest;\r\n');
		out.add('\r\n');
		out.add('/** @author gml/__macro/api/GmlGenAPI.hx */\r\n');
		out.add('@:native("") @:std extern class $className {');
		//
		var ukSpelling = false;
		var rxProp = ~/^(\w+)(\[.*?\])?([#*@&$£!;]*)$/;
		var rxFunc = ~/^(:)?(\w+)\((.*?)\)([~\$#*@&£!:;]*)$/;
		var rxArg = ~/(\[)?(\w+)(?::(\w+))?/;
		var rxWordN = ~/^\w+?\d+$/;
		var found = new Map<String, Bool>();
		each(~/^.+$/gm, raw, function(r:EReg) {
			var row = StringTools.rtrim(r.matched(0));
			var flags:String;
			inline function hasFlag(s:String):Bool {
				return flags.indexOf(s) >= 0;
			}
			if (rxProp.match(row)) {
				var name = rxProp.matched(1);
				switch (name) {
					case "true", "false": return;
				}
				if (found[name]) return;
				found.set(name, true);
				var isArray = rxProp.matched(2) != null;
				flags = rxProp.matched(3);
				if (hasFlag("&")) return;
				if (hasFlag("@")) return;
				out.add('\r\n\t');
				if (hasFlag("£") && !ukSpelling) out.add('@:noCompletion ');
				if (hasFlag("$") && ukSpelling) out.add('@:noCompletion ');
				out.add('static var $name');
				if (hasFlag("*") || hasFlag("#")) {
					out.add('(default, never)');
				}
				out.add(':');
				if (isArray) out.add('Array<');
				out.add('Dynamic');
				if (isArray) out.add('>');
				out.add(';');
			}
			else if (rxFunc.match(row)) {
				var isInst = rxFunc.matched(1) != null;
				var name = rxFunc.matched(2);
				var argData = rxFunc.matched(3);
				flags = rxFunc.matched(4);
				if (hasFlag("&")) return;
				if (found[name]) return;
				found.set(name, true);
				out.add('\r\n\t');
				if (hasFlag("£") && !ukSpelling) out.add('@:noCompletion ');
				if (hasFlag("$") &&  ukSpelling) out.add('@:noCompletion ');
				out.add('static function $name(');
				if (argData != "") {
					var argPairs = [];
					var restAt = -1;
					for (i => argStr in argData.split(",")) {
						var isRest = argStr.indexOf("...") >= 0;
						if (isRest) restAt = i;
						if (rxArg.match(argStr)) {
							var isOpt = rxArg.matched(1) != null;
							var argName = rxArg.matched(2);
							switch (argName) {
								case "var", "default", "function": {
									argName = "_" + argName;
								};
							}
							var argType = mapType(rxArg.matched(3));
							if (isRest) argType = 'Rest<$argType>';
							argPairs.push({
								name: argName,
								type: argType,
							});
						} else if (isRest) {
							argPairs.push({
								name: "rest",
								type: "Rest<Dynamic>",
							});
						} else {
							argPairs.push({
								name: "arg" + i,
								type: "Dynamic",
							});
						}
					}
					while (restAt > 0) {
						var lastArg = argPairs[restAt - 1].name;
						if (rxWordN.match(lastArg)) {
							argPairs.splice(restAt - 1, 1);
							restAt -= 1;
							Sys.println('Removed "$lastArg" from "$name"');
						} else break;
					}
					for (i => argPair in argPairs) {
						if (i > 0) out.add(", ");
						out.add(argPair.name);
						out.add(":");
						out.add(argPair.type);
					}
				}
				out.add('):');
				out.add("Dynamic");
				//out.add(hasFlag(":") ? "Dynamic" : "Void");
				out.add(';');
			}
		});
		//
		out.add('\r\n}\r\n');
		File.saveContent('$className.hx', out.toString());
		Sys.println('Updated $className!');
	}
	
	static function main() {
		proc(false);
		proc(true);
		Sys.println("OK!");
	}
	
}
#end