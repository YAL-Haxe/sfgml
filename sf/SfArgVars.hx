package sf;
import haxe.macro.Type;
import sf.type.SfArgument;
import sf.type.SfBuffer;
import sf.type.SfClassField;
import sf.type.SfField;
import sf.type.SfVar;
import SfTools.*;
import sf.SfCore.*;
using sf.type.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfArgVars {
	
	/**
	 * Generates code to copy GML arguments into actual named local variables.
	 * It can be a good idea to use argument# directly if it's used only once,
	 * but that has it's own implications.
	 */
	public static function print(r:SfBuffer, f:SfClassField) {
		var inst:Bool = f.isInst;
		//
		var expr = f.expr;
		var args = f.args;
		var argc:Int = args.length;
		var self:Int = inst ? expr.countThis() : 0;
		var i:Int, v:SfVar;
		var ropt:SfBuffer = null;
		var lp = sfConfig.localPrefix;
		if (self > 0 || argc > 0) {
			//
			var found:Int = 0;
			var arid:Int = 0;
			if (inst) {
				if (self > 0) {
					printf(r, "var this`=`argument[%d]", arid);
					found += 1;
				}
				arid += 1;
			}
			var ternary = sfConfig.ternary && !sfConfig.slowTernary;
			i = -1; while (++i < argc) {
				v = args[i].v;
				if (expr.countLocal(args[i].v) > 0) {
					var vname = sfGenerator.getVarName(v.name);
					var vdef = args[i].value;
					if (vdef == null || !ternary) {
						if (found++ > 0) r.addComma(); else r.addString("var ");
						printf(r, "%s%s", lp, vname);
					}
					if (vdef == null) {
						printf(r, "`=`argument[%d]", arid);
					} else {
						if (ropt == null) ropt = new SfBuffer();
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
			if (found > 0) printf(r, ";\n");
			if (ropt != null) r.addBuffer(ropt);
		}
	}
	
	/**
	 * Prints a documentation line for the script in "name(a:t1, b:t2, ...)" format.
	 * Flags:
	 * 1	Prepend "/// " (used in script headers)
	 * 2	Append a linebreak (also used in script headers)
	 * 4	Include short documentation, if marked with `@:doc` (used for extensions)
	 */
	public static function doc(r:SfBuffer, f:SfClassField, flags:Int = 3) {
		var jsdoc:SfBuffer = null;
		var next = sfConfig.next;
		if (flags & 3 == 3) {
			if (sfConfig.noCodeDoc) return;
			if (next) {
				jsdoc = new SfBuffer();
				jsdoc.indent = r.indent;
			}
		}
		if (flags & 1 != 0) {
			r.addString("/// ");
			if (next) r.addString("@function ");
		}
		var doc = flags & 4 != 0 ? f.doc : null;
		if (doc != null) {
			if (doc != "") {
				doc = StringTools.trim(doc);
				if (next && jsdoc != null) printf(jsdoc, "/// @description %s\n", doc);
			} else doc = null;
		}
		var argTypes = sfConfig.argTypes;
		r.addFieldPathAuto(f);
		r.addParOpen();
		var comma = false;
		if (f.isInst) {
			r.addString("this:");
			r.addString(f.parentType.name);
			if (jsdoc != null) {
				printf(jsdoc, "/// @param this:%s\n", f.parentType.name);
			}
			comma = true;
		}
		var arg:SfArgument;
		var args = f.args;
		var argc = args.length;
		// collapse trailing same-type optional arguments into "...:T":
		var emStart = argc;
		var emType = null;
		var emName:String = "";
		// catch the actual rest-argument:
		if (argc > 0) {
			arg = args[argc - 1];
			switch (arg.v.type) {
				case TAbstract(_.get() => { name: "SfRest" }, [q]): {
					emName = arg.v.name;
					emStart = argc - 1;
					emType = q;
				};
				default:
			}
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
				//if (argTypes) printf(r2, "{%(base_type)} ", avt);
				if (opt) jsdoc.addChar("?".code);
				jsdoc.addString(avn);
				if (argTypes) printf(jsdoc, ":%(base_type)", avt);
				if (def != null) printf(jsdoc, "=%(const)", def);
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
		if (doc != null) printf(r, " : %s", StringTools.trim(doc));
		if (flags & 2 != 0) r.addLine();
		if (jsdoc != null && jsdoc.length > 0) r.addString(jsdoc.toString());
	}
}
