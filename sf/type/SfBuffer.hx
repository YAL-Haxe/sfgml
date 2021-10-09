package sf.type;
import haxe.macro.Type;
import sf.SfCore.*;
import sf.opt.syntax.SfGmlRest;
import sf.type.SfArgument;
import sf.type.SfClassField;
import sf.type.SfTypeMap;

/**
 * @author YellowAfterlife
 */
class SfBuffer extends SfBufferImpl {
	override public function addLine(delta:Int = 0) {
		if (delta != 0) this.indent += delta;
		addChar("\r".code);
		addChar("\n".code);
		#if (sfgml_spaces)
		var i = indent << 2; while (--i >= 0) addChar(" ".code);
		#else
		var i = indent; while (--i >= 0) addChar("\t".code);
		#end
	}
	
	public inline function addTypePathAuto(t:SfType) {
		addTypePath(t, "_".code);
	}
	
	public function addFieldPathAuto(f:SfField) {
		if (Std.is(f, SfClassField)) {
			var cf:SfClassField = cast f;
			if (!cf.isInst && cf.parentClass.dotStatic && cf != cf.parentClass.constructor) {
				addFieldPath(f, "_".code, ".".code);
				return;
			}
		}
		addFieldPath(f, "_".code, "_".code);
	}
	
	public function addTopLevelFuncOpen(name:String, ?args:Array<SfArgument>, thisArg:Bool = false) {
		if (sfConfig.topLevelFuncs) {
			printf(this, "\nfunction %s(", name);
			if (args != null) {
				addThisArguments(thisArg, args);
			} else if (thisArg) addThisArguments(true, []);
			printf(this, ")`{%(+\n)");
		} else printf(this, "\n#define %s\n", name);
	}
	public function addTopLevelFuncOpenField(fd:SfField, ?thisArg:Bool) {
		if (sfConfig.topLevelFuncs) {
			var needsMethodClosure = fd.needsMethodClosure();
			if (!needsMethodClosure) addLine();
			//
			addTopLevelPrintIfPrefixField(fd);
			//
			if (needsMethodClosure) {
				var fda:String = sprintf("%(field_auto)", fd);
				if (fda.indexOf(".") < 0) printf(this, "globalvar %s;`", fda);
				printf(this, "%s`=`method(%type_auto, function(", fda, fd.parentType);
			} else {
				printf(this, "function %(field_auto)(", fd);
			}
			if (thisArg == null) {
				thisArg = Std.is(fd, SfClassField) ? (cast fd:SfClassField).needsThisArg() : false;
			}
			addThisArguments(thisArg, fd.args);
			printf(this, ")`{%(+\n)");
		} else printf(this, "\n#define %(field_auto)\n", fd);
	}
	public function addTopLevelPrintIfPrefix() {
		var cond = sfConfig.printIf;
		if (cond != null) {
			printf(this, "if`(%s)`", cond);
			return true;
		} else return false;
	}
	public function addTopLevelPrintIfPrefixField(fd:SfField) {
		var cond = sfConfig.printIf;
		if (cond != null && fd.needsPrintIfWrap()) {
			addTopLevelPrintIfPrefix();
			if (!fd.parentType.dotStatic
				&& (
					Std.is(fd, SfClassField) && (cast fd:SfClassField).kind.match(FMethod(_))
					|| Std.is(fd, SfEnumCtr) && (cast fd:SfEnumCtr).args.length > 0
				)
			) addLine();
			return true;
		} else return false;
	}
	public function addTopLevelFuncClose(?closeMethod:Bool) {
		if (sfConfig.topLevelFuncs) {
			printf(this, "%(-\n)}");
			if (closeMethod) printf(this, ");");
			addLine();
		} else this.addLine();
	}
	public function addTopLevelFuncCloseField(fd:SfField, ?closeMethod:Bool) {
		if (sfConfig.topLevelFuncs) {
			printf(this, "%(-\n)}");
			if (closeMethod == null) {
				closeMethod = fd.needsMethodClosure();
			}
			if (closeMethod) printf(this, ");");
			printf(this, "\n");
		} else this.addLine();
	}
	
	override public function addArguments(args:Array<SfArgument>):Void {
		var l = sfConfig.localPrefix;
		for (i in 0 ... args.length) {
			if (SfGmlRest.getRestType(args[i].v.type) != null) break;
			if (i > 0) addComma();
			addString(l);
			addString(args[i].v.name);
		}
	}
	public function addThisArguments(thisArg:Bool, args:Array<SfArgument>):Void {
		var l = sfConfig.localPrefix;
		var sep = thisArg;
		if (thisArg) addThisVar();
		for (i in 0 ... args.length) {
			if (SfGmlRest.getRestType(args[i].v.type) != null) break;
			if (sep) addComma(); else sep = true;
			addString(l);
			addString(args[i].v.name);
		}
	}
	public inline function addThisVar():Void {
		addString(sfConfig.localPrefix);
		addString("this");
	}
	
	public function addHintFoldOpen(name:String) {
		if (sfConfig.hintFolds) {
			if (sfConfig.next && !sfConfig.gmxMode) {
				addString("#region ");
			} else {
				addString("//{ ");
			}
			addString(name);
		}
	}
	
	public function addHintFoldClose() {
		if (sfConfig.hintFolds) {
			if (sfConfig.next && !sfConfig.gmxMode) {
				addString("#endregion");
			} else {
				addString("//}");
			}
		}
	}
	
	private static var docNameFieldsCache:SfTypeMap<String> = new SfTypeMap();
	private static function docNameFields(dt:DefType):String {
		switch (dt.type) {
			case TAnonymous(_.get() => at): {
				var b = new StringBuf();
				var sep = false;
				if (dt.meta.has(":dsMap")) {
					b.add("map{");
					for (fd in at.fields) {
						if (sep) b.add("; "); else sep = true;
						if (fd.meta.has(":optional")) b.add("?");
						b.add(fd.name);
					}
					b.add("}");
				} else {
					b.add("[");
					for (fd in at.fields) {
						if (sep) b.add("; "); else sep = true;
						if (fd.meta.has(":optional")) b.add("?");
						b.add(fd.name);
					}
					b.add("]");
				}
				return b.toString();
			};
			default: return dt.name;
		}
	}
	public function addBaseTypeName(t:BaseType, ?par:Array<Type>, ?dt:DefType) {
		var s = t.name;
		if (t.meta.has(":docNameFields") && dt != null) {
			s = docNameFieldsCache.baseGet(t);
			if (s == null) {
				s = docNameFields(dt);
				docNameFieldsCache.baseSet(t, s);
			}
		}
		else if (t.meta.has(":docName")) {
			switch (t.meta.extract(":docName")) {
				case [{ params: [{ expr: EConst(CString(s1)) }] }]: s = s1;
				default:
			}
		}
		else {
			var sft = sfGenerator.typeMap.baseGet(t);
			var tb = new SfBuffer();
			if (sft != null) {
				tb.addTypePathAuto(sft);
			} else {
				for (p in t.pack) { tb.addString(p); tb.addChar("_".code); }
				tb.addString(t.name);
			}
			s = tb.toString();
		}
		if (s != null && par != null && s.indexOf("$1") >= 0) {
			var n = par.length;
			while (--n >= 0) {
				var b = new SfBuffer();
				b.addMacroTypeName(par[n]);
				s = StringTools.replace(s, "$" + (n + 1), b.toString());
			}
			addString(s);
		} else {
			addString(s);
			if (par != null) {
				var n = par.length;
				if (n > 0) {
					addChar("<".code);
					var i = 0;
					while (i < n) {
						if (i > 0) addChar2(";".code, " ".code);
						addMacroTypeName(par[i]);
						i += 1;
					}
					addChar(">".code);
				}
			}
		}
	}
	public function addMacroTypeName(ot:Type) {
		var pack:Array<String>, par:Array<Type>, i:Int, n:Int, s:String;
		inline function f(t:BaseType, ?p:Array<Type>, ?dt:DefType) {
			addBaseTypeName(t, p, dt);
		}
		inline function markTypedef(t:BaseType, src:Type) {
			var sft = sfGenerator.typeMap.baseGet(t);
			if (sft == null || !sft.isStd && !sft.isExtern) {
				sfGenerator.jsdocTypedefMap.baseSet(t, {type:src, alias:t});
			}
		}
		inline function af(t:AbstractType, p:Array<Type>) {
			markTypedef(t, t.type);
			addBaseTypeName(t, p, null);
		}
		switch (ot) {
			case TEnum(_.get() => et, p): f(et, p);
			case TInst(_.get() => ct, p):
				switch (ct.kind) {
					case KTypeParameter(cns): addString(ct.name);
					default: f(ct, p);
				}
			case TType(_.get() => dt, p): {
				markTypedef(dt, dt.type);
				f(dt, p, dt);
			};
			case TFun(args, ret): {
				n = args.length;
				addString("function<");
				i = 0; while (i < n) {
					var s = args[i].name;
					if (s != null && s != "") {
						addString(args[i].name);
						addChar(":".code);
					}
					addMacroTypeName(args[i].t);
					addString("; ");
					i += 1;
				}
				addMacroTypeName(ret);
				addChar(">".code);
			};
			case TDynamic(t): {
				addString("any");
			};
			case TLazy(_() => t): addMacroTypeName(t);
			case TAbstract(_.get() => at, p): {
				//trace(at.module, at.name);
				switch (at.module) {
					case "StdTypes": switch (at.name) {
						case "Null": {
							addMacroTypeName(p[0]);
							addChar("?".code);
						};
						case "Bool": addString("bool");
						case "Int": addString("int");
						case "Float": addString("number");
						case "String": addString("string");
						case "Void": addString("void");
						default: af(at, p);
					};
					case "Any": addString("any");
					case "EnumValue": addString("any");
					case "haxe.ds.Vector": {
						addString("array");
						if (p.length > 0) printf(this, "<%base_type>", p[0]);
					}
					case "Class": {
						if (p.length > 0) switch (p[0]) {
							case TInst(_.get() => { name: "instance" }, _): {
								addString("object");
							};
							default: af(at, p);
						} else af(at, p);
					};
					default: af(at, p);
				}
			}
			default: addString("any");
		}
	}
}
