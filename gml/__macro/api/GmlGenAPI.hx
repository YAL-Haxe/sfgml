package;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
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
		var raw = File.getContent("api/" + (v2 ? "fnames" : "fnames14"));
		raw = ~/\r\n/g.replace(raw, "\n");
		//
		var repl = File.getContent('api/repl.gml');
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
		var out = new StringBuf();
		out.add('package gml.__macro;\r\n');
		out.add('\r\n');
		out.add('import gml.assets.*;\r\n');
		out.add('import haxe.extern.Rest;\r\n');
		out.add('\r\n');
		out.add('/** @author gml/__macro/api/GmlGenAPI.hx */\r\n');
		out.add('@:native("") @:std extern class GmlAPI' + (v2 ? 2 : 1) + ' {');
		//
		var ukSpelling = false;
		var rxProp = ~/^(\w+)(\[.*?\])?([#*@&$£!;]*)$/;
		var rxFunc = ~/^(:)?(\w+)\((.*?)\)([~\$#*@&£!:;]*)$/;
		var rxArg = ~/(\w+)(?::(\w+))?/;
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
			} else if (rxFunc.match(row)) {
				var isInst = rxFunc.matched(1) != null;
				var name = rxFunc.matched(2);
				var argd = rxFunc.matched(3);
				flags = rxFunc.matched(4);
				if (hasFlag("&")) return;
				if (found[name]) return;
				found.set(name, true);
				out.add('\r\n\t');
				if (hasFlag("£") && !ukSpelling) out.add('@:noCompletion ');
				if (hasFlag("$") &&  ukSpelling) out.add('@:noCompletion ');
				out.add('static function $name(');
				if (argd != "") {
					var args = argd.split(",");
					for (i in 0 ... args.length) {
						var arg = args[i];
						if (i > 0) out.add(', ');
						var isRest = arg.indexOf("...") >= 0;
						if (rxArg.match(arg)) {
							var argName = rxArg.matched(1);
							switch (argName) {
								case "default": {
									out.add("_");
								};
							}
							out.add(argName);
							out.add(':');
							if (isRest) out.add('Rest<');
							out.add(mapType(rxArg.matched(2)));
							if (isRest) out.add('>');
						} else if (isRest) {
							out.add('rest:Rest<Dynamic>');
						} else out.add('arg' + i + ':Dynamic');
					}
				}
				out.add('):');
				out.add(hasFlag(":") ? "Dynamic" : "Void");
				out.add(';');
			}
		});
		//
		out.add('\r\n}\r\n');
		File.saveContent('GmlAPI' + (v2 ? 2 : 1) + '.hx', out.toString());
	}
	
	static function main() {
		proc(false);
		proc(true);
		Sys.println("OK!");
	}
	
}
