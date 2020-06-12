package sf;
import haxe.macro.Type;
import sf.type.SfArgument;
import sf.type.SfBuffer;
import sf.type.SfClassField;
import sf.type.SfField;
import sf.type.SfVar;
import SfTools.*;
import sf.SfCore.*;
import sf.type.expr.SfExpr;
import sf.opt.syntax.SfGmlWith;
using sf.type.expr.SfExprTools;

class SfArgVars {
	public static function printExt(r:SfBuffer, expr:SfExpr, args:Array<SfArgument>, flags:SfArgVarsExt) {
		var argc:Int = args.length;
		var showArgs = false;
		var i:Int, v:SfVar, arg:SfArgument;
		i = -1; while (++i < argc) {
			arg = args[i];
			if (!arg.hidden) {
				showArgs = true;
			}
		}
		//
		var checkThis = flags.hasAny(SfArgVarsExt.ThisArg | SfArgVarsExt.ThisSelf);
		var showThis:Bool;
		if (checkThis) {
			if (flags.has(SfArgVarsExt.ThisSelf)) {
				showThis = SfGmlWith.needsThisSelf(expr);
			} else {
				// leave `this` in if it's the only argument - else GM will be upset about us
				// calling a function that takes no arguments.
				showThis = argc == 0 || expr.countThis() > 0;
			}
		} else showThis = false;
		
		//
		var lp = sfConfig.localPrefix;
		if (sfConfig.modern) {
			if (showThis && flags.has(SfArgVarsExt.ThisSelf)) {
				printf(r, "var this`=`self;\n");
			}
			var hasOpt = false;
			for (arg in args) {
				var v = arg.value;
				if (v == null) continue;
				hasOpt = true;
				if (v == TNull) continue;
				var s = arg.v.name;
				printf(r, "if`(%(var)`==`undefined)`%(var)`=`%(const);\n", s, s, v);
			}
			// this is purely a countermeasure for IDE not shutting up about "extra arguments"
			if (hasOpt) printf(r, "if`(false)`throw argument[%d];\n", args.length - 1);
			return;
		}
		
		//
		var ropt:SfBuffer = null;
		var found:Int = 0;
		var arid:Int = 0;
		if (showThis) {
			if (flags.has(SfArgVarsExt.ThisSelf)) {
				printf(r, "var this`=`self");
				found += 1;
			} else {
				printf(r, "var this`=`argument[%d]", arid);
				found += 1;
				arid += 1;
			}
		} else if (checkThis) {
			// "this" argument is not needed but we'll keep it in mind
			arid += 1;
		}
		//
		if (showArgs) {
			var ternary = sfConfig.ternary && !sfConfig.avoidTernaries;
			i = -1; while (++i < argc) {
				arg = args[i];
				v = arg.v;
				if (!arg.hidden) {
					var vname = sfGenerator.getVarName(v.name);
					var vdef = arg.value;
					if (vdef == null || !ternary) {
						if (found++ > 0) r.addComma(); else r.addString("var ");
						printf(r, "%s%s", lp, vname);
						if (sfConfig.hintVarTypes) {
							var t = sf.opt.type.SfGmlTypeHint.get(v.type);
							//printf(r, '/*%s*/', Std.string(v.type));
							if (t != null) printf(r, "/*:%s*/", t);
						}
					}
					if (vdef == null) {
						printf(r, "`=`argument[%d]", arid);
					} else {
						if (ropt == null) {
							ropt = new SfBuffer();
							ropt.indent = r.indent;
						}
						if (ternary) {
							printf(ropt, "var %s%s`=`argument_count`>`%d`", lp, vname, arid);
							printf(ropt, "?`argument[%d]`:`%(const);\n", arid, vdef);
						} else {
							printf(ropt, "if`(argument_count`>`%d)", arid);
							printf(ropt, "`%s%s`=`argument[%d];", lp, vname, arid);
							printf(ropt, "`else %s%s`=`%(const);\n", lp, vname, vdef);
						}
					}
				}
				arid += 1;
			};
		}
		if (found > 0) printf(r, ";\n");
		if (ropt != null) r.addBuffer(ropt);
	}
	/**
	 * Generates code to copy GML arguments into actual named local variables.
	 * Also see SfGmlArgs for a mini-optimization with replacing single-use
	 * arguments by their argument[ind].
	 */
	public static function print(r:SfBuffer, f:SfClassField) {
		var flags:SfArgVarsExt = 0;
		if (f.isSelfCall()) {
			flags |= SfArgVarsExt.ThisSelf;
		} else if (f.needsThisArg()) {
			flags |= SfArgVarsExt.ThisArg;
		}
		printExt(r, f.expr, f.args, flags);
	}
	
	/**
	 * Prints a documentation line for the script in "name(a:t1, b:t2, ...)" format.
	 * Flags:
	 * 1	Prepend "/// " (used in script headers)
	 * 2	Append a linebreak (also used in script headers)
	 * 4	Include short documentation, if marked with `@:doc` (used for extensions)
	 */
	public static function doc(r:SfBuffer, f:SfField, flags:Int = 3) {
		var jsdoc:SfBuffer = null;
		var ext = sfConfig.gmxMode;
		var next = sfConfig.next;
		var modern = sfConfig.modern;
		var showDoc = f.checkDocState(f.parentType.docState);
		//
		var arg:SfArgument;
		var args = f.args;
		var argc = args.length;
		// collapse trailing same-type optional arguments into "...:T":
		var emStart = argc;
		var emType:Type = null;
		var emName:String = "";
		// catch the actual rest-argument:
		if (argc > 0) {
			arg = args[argc - 1];
			emType = sf.opt.syntax.SfGmlRest.getRestType(arg.v.type);
			if (emType != null) {
				emName = arg.v.name;
				emStart = argc - 1;
			}
		}
		//
		if (flags & 3 == 3) {
			if (sfConfig.noCodeDoc) return;
			if (next && !ext && showDoc) {
				jsdoc = new SfBuffer();
				jsdoc.indent = r.indent;
			}
		}
		if (flags & 1 != 0) {
			if (ext || !showDoc) {
				r.addString("// ");
			} else {
				r.addString("/// ");
			}
		}
		var doc = flags & 4 != 0 ? f.doc : null;
		if (doc != null) {
			if (doc != "") {
				doc = StringTools.trim(doc);
				if (jsdoc != null) printf(jsdoc, "/// @description %s\n", doc);
			} else doc = null;
		}
		var argTypes = sfConfig.argTypes;
		r.addFieldPathAuto(f);
		r.addParOpen();
		var comma = false;
		if (Std.is(f, SfClassField) && (cast f:SfClassField).needsThisArg()) {
			r.addString("this:");
			r.addString(f.parentType.name);
			if (jsdoc != null) {
				printf(jsdoc, "/// @param this:%s\n", f.parentType.name);
			}
			comma = true;
		}
		// otherwise see if there are trailing optionals that are all the same:
		if (emStart >= argc && argc >= 4) {
			arg = args[argc - 1];
			if (arg.value != null) {
				emType = arg.v.type;
				emStart -= 2;
				while (emStart >= 0) {
					arg = args[emStart];
					if (arg.value == null) break;
					if (!arg.v.type.typeEquals(emType)) break;
					emStart -= 1;
				}
				// only collapse if there are at least 4 same-type opt.args:
				if (emStart < argc - 4) {
					emStart += 1;
				} else emStart = argc;
			}
		}
		//
		var argSfxCounters = new Map();
		var rxArgSuffix = ~/^(\w+)(\d+)$/;
		inline function desuffix(avn:String):String {
			if (rxArgSuffix.match(avn)) {
				var avi:Int;
				avn = rxArgSuffix.matched(1);
				if (argSfxCounters.exists(avn)) {
					avi = argSfxCounters[avn];
				} else avi = 0;
				argSfxCounters.set(avn, avi);
				if (avi > 0) avn += avi;
			}
			return avn;
		}
		// print actual arguments:
		for (i in 0 ... emStart) {
			arg = args[i];
			if (comma) printf(r, ", "); else comma = true;
			var def = arg.value;
			var avn = arg.v.name;
			var avt = arg.v.type;
			// `arg:Null<T>` -> `?arg:T`:
			var opt = false;
			if (def != null && def.match(TNull)) {
				opt = true;
				def = null;
				switch (avt) {
					case TAbstract(_.get() => { name: "Null" }, [t]): avt = t;
					default: 
				}
			}
			//
			if (opt) r.addChar("?".code);
			if (rxArgSuffix.match(avn)) {
				var avi:Int;
				avn = rxArgSuffix.matched(1);
				if (argSfxCounters.exists(avn)) {
					avi = argSfxCounters[avn];
				} else avi = 0;
				argSfxCounters.set(avn, avi);
				if (avi > 0) avn += avi;
			}
			avn = desuffix(avn);
			r.addString(avn);
			if (argTypes) printf(r, ":%(base_type)", avt);
			if (def != null) printf(r, " = %(const)", def);
			//
			if (jsdoc != null) {
				jsdoc.addString("/// @param ");
				if (argTypes) printf(jsdoc, "{%(base_type)} ", avt);
				if (opt) jsdoc.addChar("[".code);
				jsdoc.addString(avn);
				if (def != null) printf(jsdoc, "=%(const)", def);
				if (opt) jsdoc.addChar("]".code);
				jsdoc.addLine();
			}
		}
		// print rest-argument:
		if (emStart < argc) {
			if (comma) printf(r, ", ");
			emName = desuffix(emName);
			printf(r, "...%s", emName);
			if (argTypes) printf(r, ":%(base_type)", emType);
			if (jsdoc != null) {
				jsdoc.addString("/// @param ");
				//if (argTypes) printf(r2, "{%(base_type)} ", emType);
				printf(jsdoc, "...%s", emName);
				if (argTypes) printf(r, ":%(base_type)", emType);
				jsdoc.addLine();
			}
		}
		r.addParClose();
		// print return type:
		if (argTypes) switch (f.type) {
			case TAbstract(_.get() => at, _) if (at.name == "Void"):
			default: {
				r.addString("->");
				r.addBaseTypeName(f.type);
				/*if (r2 != null && argTypes) {
					r2.addString("/// @return {");
					r2.addBaseTypeName(f.type);
					r2.addString("}");
					r2.addLine();
				}*/
			};
		}
		// print @:doc:
		if (flags & 2 != 0) r.addLine();
		if (jsdoc != null && jsdoc.length > 0) r.addString(jsdoc.toString());
		if ((ext || jsdoc == null) && doc != null && doc.indexOf("\n") < 0) printf(r, "// %s", doc);
	}
}
enum abstract SfArgVarsExt(Int) from Int to Int {
	var ThisArg = 1;
	var ThisSelf = 2;
	public function has(flag:SfArgVarsExt):Bool {
		return (this & flag) == flag;
	}
	public inline function hasAny(flag:SfArgVarsExt):Bool {
		return (this & flag) != 0;
	}
	@:op(A|B) public inline function or(flag:SfArgVarsExt):SfArgVarsExt {
		return this | flag;
	}
}
