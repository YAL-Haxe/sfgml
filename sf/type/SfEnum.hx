package sf.type;
import haxe.macro.Type.MetaAccess;
import sf.SfArgVars;
import sf.type.SfBuffer;
import sf.SfCore.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfEnum extends SfEnumImpl {
	public var ctrNames:Bool = false;
	public function new(t) {
		super(t);
	}
	override public function printTo(outb:SfBuffer, initb:SfBuffer):Void {
		if (isHidden) return;
		if (isFake && nativeGen && !SfCore.sfConfig.gmxMode) {
			printf(initb, "enum %(type_auto) {", this);
			var sep = false;
			for (f in ctrList) {
				if (sep) initb.addComma(); else { sep = true; initb.addSep(); }
				initb.addString(f.name);
			}
			printf(initb, "`}\n");
		}
		if (isFake) return;
		var out = new SfBuffer(), init = new SfBuffer();
		var hintFolds = sfConfig.hintFolds;
		var debug = sfConfig.debug;
		var canRef = !this.noRef;
		var hasAC = sfConfig.hasArrayCreate;
		var pureArray = sfConfig.hasArrayDecl && nativeGen;
		var noScripts = pureArray && docState <= 0;
		for (ctr in ctrList) {
			var args:Array<SfArgument> = ctr.args;
			var argc:Int = args.length;
			var path:String = ctr.getPathAuto();
			if (argc == 0 && canRef) {
				printf(init, "globalvar g_%s;`", path);
				printf(init, "g_%s`=`", path);
				if (pureArray) {
					printf(init, "[%d%(hint)]", ctr.index, ctr.name);
				} else printf(init, "%s_new()", path);
				printf(init, ";\n");
				path += "_new";
			}
			if (noScripts) continue;
			out.addTopLevelFuncOpen(path);
			SfArgVars.doc(out, ctr);
			//
			printf(out, "var this");
			if (hasAC) printf(out, "`=`array_create(%d)", argc + 1);
			printf(out, ";\n");
			//
			if (!nativeGen) {
				#if !sfgml_legacy_meta
				// todo: we can't just add overhead of metadata check to every ADT value retrieval
				#else
				if (debug) printf(out, 'this[1,1]`=`"%s";\n', ctr.name);
				if (sf.opt.SfGmlType.usesType) {
					printf(out, "this[1,0]`=`mt_%(type_auto);\n", this);
				}
				#end
			}
			//
			printf(out, "this[0%(hint)]`=`%d;\n", "id", ctr.index);
			for (i in 0 ... argc) {
				var arg = args[i];
				inline function addArgSet():Void {
					printf(out, "this[%d%(hint)]`=`", i + 1, arg.v.name);
				}
				if (arg.value != null) {
					if (sfConfig.ternary) {
						addArgSet();
						printf(out, "argument_count`>`%d`?`argument[%d]`:`", i, i);
						sfGenerator.printConst(out, arg.value, null);
					} else {
						printf(out, "if`(argument_count`>`%d)`{%(+\n)", i, i);
						addArgSet();
						printf(out, "argument[%d];", i);
						printf(out, "%(-\n)}`else`{%(+\n)");
						addArgSet();
						sfGenerator.printConst(out, arg.value, null);
						printf(out, ";%(-\n)}");
					}
				} else {
					addArgSet();
					printf(out, "argument[%d]", i);
				}
				printf(out, ";\n");
			}
			//
			printf(out, "return this;");
			out.addTopLevelFuncClose();
		}
		if (out.length > 0) {
			if (hintFolds) printf(outb, "\n//{ %(type_dot)\n", this);
			outb.addBuffer(out);
			if (hintFolds) printf(outb, "\n//}\n");
		}
		if (init.length > 0) {
			if (hintFolds) printf(initb, "// %(type_dot):\n", this);
			initb.addBuffer(init);
		}
	}
}

