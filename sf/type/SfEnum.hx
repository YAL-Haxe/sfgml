package sf.type;
import haxe.macro.Type.MetaAccess;
import sf.SfArgVars;
import sf.type.SfBuffer;
import sf.SfCore.*;
import sf.type.SfClassField;
import sf.type.SfEnumCtr;

/**
 * ...
 * @author YellowAfterlife
 */
class SfEnum extends SfEnumImpl {
	
	/** Whether constructor names should be included */
	public var ctrNames:Bool = false;
	
	public function new(t) {
		super(t);
		if (sfConfig.modern && (nativeGen || isFake)) {
			isStruct = false;
			dotAccess = false; // not that you can dot access anything on enums anyway
		}
		
		// for structs, rename arguments that clash with built-ins:
		if (isStruct) for (ctr in ctrList) {
			for (arg in ctr.args) {
				var v0 = arg.v.name;
				var v1 = sfGenerator.getFieldName(v0);
				if (v1 != v0) {
					arg.v.name = v1;
				}
			}
		}
	}
	
	/** Whether this enum will need a enum_toString generated */
	public function needsToString():Bool {
		return !isHidden && isStruct;
	}
	
	/** Will this enum have a GML enum to go along with it? */
	public function hasNativeEnum():Bool {
		if (sfConfig.gmxMode) return false;
		return nativeGen;
	}
	
	public function isPureArray():Bool {
		return !isStruct && sfConfig.hasArrayDecl && !(!nativeGen && sfConfig.legacyMeta);
	}
	
	private function printCtrIndexLiteral(out:SfBuffer, ctr:SfEnumCtr):Void {
		if (hasNativeEnum()) {
			out.addFieldPath(ctr, "_".code, ".".code);
		} else {
			out.addInt(ctr.index);
		}
	}
	
	function printNativeEnum(out:SfBuffer):Void {
		out = sfGenerator.declBuffer;
		printf(out, "enum %(type_auto)`{`", this);
		var sep = false;
		for (f in ctrList) {
			if (sep) out.addComma(); else sep = true;
			out.addString(f.name);
		}
		printf(out, "`}\n");
	}
	
	static var toStringPath:String = null;
	static var getIndexPath:String = null;
	function printStruct(outb:SfBuffer, initb:SfBuffer):Void {
		var stdPre = sfConfig.stdPack;
		stdPre = stdPre != null ? stdPre + "_" : "";
		if (toStringPath == null) {
			toStringPath = stdPre + "enum_toString";
			getIndexPath = stdPre + "enum_getIndex";
			//
			var decl = sfGenerator.declBuffer;
			decl.addTopLevelPrintIfPrefix();
			printf(decl, "function %s()`{%(+\n)", toStringPath);
			var Std_string = sfGenerator.findRealClassField("Std", "string");
			if (Std_string != null) {
				printf(decl, "return %(field_auto)(self);", Std_string);
			} else {
				printf(decl, "return string(self);");
			}
			printf(decl, "%(-\n)}\n");
			//
			decl.addTopLevelPrintIfPrefix();
			printf(decl, "function %s%s()`{%(+\n)", stdPre, "enum_getIndex");
			printf(decl, "return __enumIndex__;");
			printf(decl, "%(-\n)}\n");
		}
		//
		var out = new SfBuffer(), init = new SfBuffer();
		if (hasNativeEnum()) printNativeEnum(init);
		out.addLine();
		out.addTopLevelPrintIfPrefix();
		printf(out, "function mc_%(type_auto)()`constructor`{%(+\n)", this);
		printf(out, "static getIndex`=`method(undefined,`%s);\n", getIndexPath);
		printf(out, "static toString`=`method(undefined,`%s);\n", toStringPath);
		printf(out, "static __enum__`=`mt_%(type_auto);", this);
		printf(out, "%(-\n)};\n");
		//
		function addEnumParamsLiteral(ctr:SfEnumCtr) {
			printf(out, "[");
			for (i => arg in ctr.args) {
				if (i > 0) out.addComma();
				printf(out, '"%s"', arg.v.name);
			}
			printf(out, "]");
		}
		var avoidStaticArrayDeclarations = sfConfig.avoidStaticArrayDeclarations;
		//
		for (ctr in ctrList) {
			if (avoidStaticArrayDeclarations) {
				out.addLine();
				out.addTopLevelPrintIfPrefixField(ctr);
				printf(out, "global.__mp_%(field_auto)`=`", ctr);
				addEnumParamsLiteral(ctr);
				out.addSemico();
			}
			out.addLine();
			out.addTopLevelPrintIfPrefixField(ctr);
			printf(out, "function mc_%(field_auto)()", ctr);
			printf(out, "`:`mc_%(type_auto)()", this);
			printf(out, "`constructor`{%(+\n)");
			//
			printf(out, "static __enumParams__`=`");
			if (avoidStaticArrayDeclarations) {
				printf(out, "global.__mp_%(field_auto)", ctr);
			} else addEnumParamsLiteral(ctr);
			printf(out, ";\n");
			printf(out, "static __enumIndex__`=`");
			printCtrIndexLiteral(out, ctr);
			printf(out, ";%(-\n)};\n");
			//
			if (ctr.args.length == 0 && !noRef) {
				printf(out, "globalvar %(field_auto);`", ctr);
				out.addTopLevelPrintIfPrefix();
				printf(out, "%(field_auto)`=`new mc_%(field_auto)();\n", ctr, ctr);
			} else {
				out.addTopLevelFuncOpenField(ctr);
				SfArgVars.doc(out, ctr);
				printf(out, "var %this`=`new mc_%(field_auto)();\n", ctr);
				var hasOpt = false;
				for (i in 0 ... ctr.args.length) {
					var arg = ctr.args[i];
					printf(out, "%this.%s`=`%(var);\n", arg.v.name, arg.v.name);
					if (arg.value != null) hasOpt = true;
				}
				if (hasOpt) printf(out, "if`(false)`return argument[%d];\n", ctr.args.length - 1);
				printf(out, "return %this");
				out.addTopLevelFuncCloseField(ctr);
			}
		}
		//
		if (out.length > 0) {
			var fq = getRegionName();
			var splitBuf = sfGenerator.getSplitBuf(fq);
			var b = splitBuf != null ? splitBuf : outb;
			if (sfConfig.hintFolds) printf(b, "\n%(+region)\n", fq);
			b.addBuffer(out);
			if (sfConfig.hintFolds) printf(b, "\n%(-region)\n");
		}
		if (init.length > 0) {
			if (sfConfig.hintFolds) printf(initb, "// %(type_dot):\n", this);
			initb.addBuffer(init);
		}
	}
	function printLinear(outb:SfBuffer, initb:SfBuffer):Void {
		var init = new SfBuffer();
		// if it's a fake enum, we'll stick to a native enum or macros (SfGmxGen)
		var nativeEnum = hasNativeEnum();
		if (nativeEnum) printNativeEnum(init);
		if (isFake) {
			if (init.length > 0) {
				if (sfConfig.hintFolds) printf(initb, "// %(type_dot):\n", this);
				initb.addBuffer(init);
			}
			return;
		}
		
		var out = new SfBuffer();
		var debug = sfConfig.debug;
		var canRef = !this.noRef;
		var hasAC = sfConfig.hasArrayCreate;
		var hasLegacyMeta = !nativeGen && sfConfig.legacyMeta;
		var pureArray = isPureArray();
		var noScripts = pureArray && docState <= 0;
		var g_ = sfConfig.gmxMode ? "g_" : "";
		for (ctr in ctrList) {
			var args:Array<SfArgument> = ctr.args;
			var argc:Int = args.length;
			var path:String = ctr.getPathAuto();
			if (argc == 0 && canRef) {
				printf(init, "globalvar %s%s;`", g_, path);
				printf(init, "%s%s`=`", g_, path);
				if (pureArray) {
					printf(init, "[");
					if (nativeEnum) {
						init.addFieldPath(ctr, "_".code, ".".code);
					} else {
						printf(init, "%d%(hint)", ctr.index, ctr.name);
					}
					printf(init, "]");
				} else printf(init, "mc_%s()", path);
				printf(init, ";\n");
				if (pureArray) continue;
				path = "mc_" + path;
			}
			if (noScripts) continue;
			out.addTopLevelFuncOpen(path);
			SfArgVars.doc(out, ctr);
			//
			if (pureArray) {
				printf(out, "return [%(+\n)");
				printCtrIndexLiteral(out, ctr);
				for (i in 0 ... argc) {
					printf(out, ",\n");
					var arg = args[i];
					if (arg.value != null) {
						printf(out, "argument_count`>`%d`?`argument[%d]`:`", i, i);
						sfGenerator.printConst(out, arg.value, null);
					} else {
						printf(out, "argument[%d]", i);
					}
				}
				printf(out, "%(-\n)];");
			} else {
				//
				printf(out, "var this");
				if (hasAC) printf(out, "`=`array_create(%d)", argc + 1);
				printf(out, ";\n");
				//
				if (hasLegacyMeta) {
					if (debug) printf(out, 'this[1,1]`=`"%s";\n', ctr.name);
					if (sf.opt.type.SfGmlType.usesType) {
						printf(out, "this[1,0]`=`mt_%(type_auto);\n", this);
					}
				}
				//
				printf(out, "this[0%(hint)]`=`", "id");
				printCtrIndexLiteral(out, ctr);
				printf(out, ";\n");
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
			}
			out.addTopLevelFuncClose();
		}
		if (out.length > 0) {
			if (sfConfig.hintFolds) printf(outb, "\n%(+region)\n", sprintf("%type_dot", this));
			outb.addBuffer(out);
			if (sfConfig.hintFolds) printf(outb, "\n%(-region)\n");
		}
		if (init.length > 0) {
			if (sfConfig.hintFolds) printf(initb, "// %(type_dot):\n", this);
			initb.addBuffer(init);
		}
	}
	override public function printTo(outb:SfBuffer, initb:SfBuffer):Void {
		if (isHidden) return;
		//
		if (isFake && docState >= 0 && !sfConfig.gmxMode && !hasNativeEnum()) {
			for (ctr in ctrList) {
				if (!ctr.checkDocState(docState)) continue;
				printf(sfGenerator.declBuffer, "#macro %field_auto %d\n", ctr, ctr.index);
			}
		}
		//
		if (isStruct) {
			printStruct(outb, initb);
		} else {
			printLinear(outb, initb);
		}
	}
}

