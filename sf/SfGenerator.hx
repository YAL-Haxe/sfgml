package sf;
import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Binop;
import haxe.macro.Expr.Position;
import haxe.macro.JSGenApi;
import haxe.macro.Expr.Binop.*;
import haxe.macro.Expr.Unop.*;
import haxe.macro.Type.TConstant;
import haxe.macro.Type.TypedExpr;
import sf.SfArgVars;
import sf.opt.*;
import sf.opt.api.*;
import sf.opt.legacy.*;
import sf.opt.syntax.*;
import sf.opt.type.*;
import sf.type.*;
import sf.type.expr.*;
import sf.type.expr.*;
import sf.type.SfTypeMap;
import sf.type.expr.SfExprDef.*;
import sf.type.expr.SfExpr;
import SfTools.*;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGenerator extends SfGeneratorImpl {
	public var declBuffer:SfBuffer;
	/** In 2.3 extension mode, we want static function `#define`s after the init function with globalvar setup */
	public var staticFuncBuffer:SfBuffer;
	/** In 2.3 extension mode, we want constructors before the rest of the code in init function */
	public var constructorBuffer:SfBuffer;
	public static function main() {
		SfConfig.main();
	}
	
	var startTime:Float = Sys.time();
	public function new() {
		super();
		Compiler.addClassPath(Context.resolvePath("gml/std"));
	}
	
	private function printTypeGrid(init:SfBuffer) {
		if (sfConfig.modern) return;
		if (sfConfig.hintFolds) printf(init, "//{ g_haxe_type_is\n");
		var grid = "haxe_type_is";
		if (sfConfig.stdPack != null) grid = sfConfig.stdPack + "_" + grid;
		var n = SfType.indexes;
		printf(init, "globalvar %s;`", grid);
		printf(init, "%s`=`ds_grid_create(%d,`%d);\n", grid, n, n);
		printf(init, "for`(var _g_type`=`0;`_g_type`<`%d;`_g_type`+=`1)`", n);
		printf(init, "%s[#_g_type, _g_type]`=`true;\n", grid);
		for (c in classList) if (c.isUsed && c.index >= 0) {
			var i = c.index;
			var p = c.superClass;
			while (p != null) {
				if (p.isUsed && p.index >= 0) {
					printf(init, "%s[#%d,`%d]`=`true;\n", grid, i, p.index);
				}
				p = p.superClass;
			}
		}
		if (sfConfig.hintFolds) printf(init, "//}\n");
	}
	override public function printTo(path:String) {
		var hintFolds = sfConfig.hintFolds;
		var hint = sfConfig.hint;
		// Haxe compiler overwrites the target file, but you don't want that if modifying it:
		var ext = Path.extension(path).toLowerCase();
		if (ext == "hx" || ext == "_") {
			path = Path.withoutExtension(path);
			ext = Path.extension(path).toLowerCase();
		}
		// Extension generation (which will execute printTo for actual extension path):
		if (StringTools.endsWith(path.toLowerCase(), ".extension.gmx")) {
			SfGmxGen.run(path);
			return;
		}
		if (StringTools.endsWith(path.toLowerCase(), ".yy")) {
			if (sfConfig.gmxMode) {
				SfYyGen.run(path);
				return;
			} else path = Path.withExtension(path, "gml");
		}
		//
		var next = sfConfig.next;
		var hasArrayDecl = sfConfig.hasArrayDecl;
		(new SfGmlSnakeCase()).apply();
		//
		var mixed:SfBuffer = new SfBuffer();
		var out:SfBuffer = new SfBuffer();
		var init:SfBuffer = new SfBuffer();
		var decl:SfBuffer = new SfBuffer(); declBuffer = decl;
		var sepStaticFuncs = sfConfig.modern && sfConfig.gmxMode;
		constructorBuffer = sepStaticFuncs ? new SfBuffer() : out;
		staticFuncBuffer = sepStaticFuncs ? new SfBuffer() : out;
		// inline entry point, if needed:
		if (mainExpr != null) switch (mainExpr.def) {
			case SfCall(_.def => SfStaticField(_, f), []): {
				switch (f.classField.kind) {
					case FMethod(MethInline): {
						mainExpr = f.expr;
						f.isHidden = true;
					};
					default:
				}
			};
			default:
		}
		//
		if (sfConfig.entrypoint != "" && !(
			sfConfig.topLevelFuncs && !sfConfig.gmxMode
		)) {
			printf(mixed, "#define %s\n", sfConfig.entrypoint);
		}
		var cond = sfConfig.printIf;
		//if (cond != null) printf(init, "if (%s) {\n", cond);
		//
		if (sfConfig.header != null) {
			for (line in sfConfig.header.split("\n")) printf(mixed, "%s\n", line);
		}
		if (SfGml_StdTypeImpl.isUsed) printTypeGrid(decl);
		if (SfGml_Type_enumHelpers.code != "") {
			if (hintFolds) printf(decl, "//{ enum names\n");
			decl.addString(SfGml_Type_enumHelpers.code);
			if (hintFolds) printf(decl, "//}\n");
		}
		//
		if (SfGmlType.usesProto) SfGmlTypeInit.printProto(decl);
		SfGmlScriptRefs.main(decl);
		if (SfGmlType.usesType) SfGmlTypeInit.printMeta(decl);
		
		// generate class inits:
		for (c in classList) if (!SfExprTools.isEmpty(c.init)) {
			var len = init.length;
			init.addExpr(c.init, SfPrintFlags.StatWrap);
			if (init.length > len) {
				init.addSemico();
				init.addLine();
			}
		}
		
		// generate static field init and the entrypoint call:
		for (t in typeList) {
			t.printTo(out, init);
		}
		
		// print header and save:
		if (sfConfig.timestamp) {
			var now = Date.now().toString();
			var ms = Std.int((Sys.time() - startTime) * 1000);
			var ver = sfConfig.version;
			printf(mixed, "// Generated at %s (%(d)ms) for v%s+\n", now, ms, ver);
		}
		
		//
		function addMainExpr(b:SfBuffer):Void {
			if (mainExpr != null) {
				var wrap = b.addTopLevelPrintIfPrefix();
				b.addExpr(mainExpr, wrap ? SfPrintFlags.Stat : SfPrintFlags.StatWrap);
				b.addSemico();
				b.addLine();
			}
		}
		if (sepStaticFuncs) mixed.addBuffer(constructorBuffer);
		mixed.addBuffer(decl);
		if (sfConfig.modern) {
			mixed.addBuffer(out);
			var ep = sfConfig.entrypoint;
			var wrapEp = ep != "" && !sfConfig.gmxMode;
			if (wrapEp) printf(mixed, "function %s()`{", ep);
			mixed.addLine();
			mixed.addBuffer(init);
			mixed.addLine();
			addMainExpr(mixed);
			if (wrapEp) printf(mixed, "}");
			if (sepStaticFuncs) mixed.addBuffer(staticFuncBuffer);
		} else {
			addMainExpr(init);
			mixed.addBuffer(init);
			mixed.addBuffer(out);
		}
		//
		var mixedStr = mixed.toString();
		if (!sfConfig.timestamp && sfConfig.entrypoint == "" && mainExpr.isEmpty()) {
			mixedStr = StringTools.ltrim(mixedStr);
		}
		sys.io.File.saveContent(path, mixedStr);
	}
	
	private static var identRx:EReg = ~/[A-Za-z_]/g;
	override public function printConst(r:SfBuffer, value:TConstant, expr:SfExpr) {
		var pos = expr != null ? expr.getPos() : null;
		switch (value) {
			case TInt(i): {
				#if (sf_hint_const)
				var src = pos.getSource();
				var z = true;
				if (src == null) {
					// don't touch
				} else if (src.indexOf("0x") >= 0) {
					printf(r, "$%s", StringTools.hex(i)); z = false;
				} else if (src.indexOf('".code') >= 0 || src.indexOf("'.code") >= 0) {
					if (i == 92) {
						if (sfConfig.next) {
							printf(r, 'ord("\\\\")');
						} else printf(r, 'ord("\\")');
					} else if (i >= 32) {
						printf(r, 'ord("%c")', i);
						//printf(r, "/* '%c' */", i);
						z = false;
					} else if (sfConfig.next) {
						var s:String = switch (i) {
							case "\r".code: "\\r";
							case "\n".code: "\\n";
							case "\t".code: "\\t";
							case 8/* \b */: "\\b";
							case 92: String.fromCharCode(92);
							default: null;
						}
						if (s != null) {
							printf(r, 'ord("%s")', s);
							z = false;
						}
					}
				}
				if (z) r.addInt(i);
				#else
				r.addInt(i);
				#end
			};
			case TFloat(s): {
				#if (sf_hint_const)
				var p = s.indexOf(".");
				if (p >= 0 && s.length - p > 6) {
					var src = pos.getSource();
					if (src != null && !identRx.match(src)) {
						printf(r, "(%s)", src);
					} else r.addString(s);
				} else r.addString(s);
				#else
				r.addString(s);
				#end
			};
			case TString(s): {
				if (sfConfig.next) {
					printf(r, '"');
					for (i in 0 ... s.length) {
						var c = StringTools.fastCodeAt(s, i);
						switch (c) {
							case "\n".code: printf(r, '\\n');
							case "\r".code: printf(r, '\\r');
							case "\t".code: printf(r, '\\t');
							case "\"".code: printf(r, '\\"');
							case "\\".code: printf(r, '\\\\');
							default: r.addChar(c);
						}
					}
					printf(r, '"');
				} else {
					switch (s) {
						case "\r": r.addString("chr(13)");
						case "\n": r.addString("chr(10)");
						case "\r\n": r.addString("(chr(13) + chr(10))");
						default: {
							if (s.length == 1 && s.charCodeAt(0) < 32) {
								printf(r, "chr(%d)", s.charCodeAt(0));
							} else {
								var q:Int = if (s.indexOf('"') < 0) {
									'"'.code;
								} else if (s.indexOf("'") < 0) {
									"'".code;
								} else '"'.code;
								//
								var start = 0;
								var pos = 0;
								var len = s.length;
								var last = len - 1;
								while (pos < len) {
									var c = StringTools.fastCodeAt(s, pos);
									if (c < 32 || c == q) {
										if (start == 0) {
											r.indent += 1;
											printf(r, "(");
											if (pos > 0) {
												printf(r, "%c%s%c", q, s.substring(0, pos), q);
											}
										} else if (pos > start) {
											printf(r, "`+`%c%s%c", q, s.substring(start, pos), q);
										}
										if (pos > 0) printf(r, "`+`");
										printf(r, "chr(%d)", c);
										if (c == 10 && pos < last) printf(r, "\n");
										start = pos + 1;
									}
									pos += 1;
								}
								if (start > 0) {
									if (start < pos) {
										printf(r, "`+`%c%s%c", q, s.substring(start, pos), q);
									}
									r.indent -= 1;
									printf(r, ")");
								} else {
									r.addChar(q);
									r.addString(s);
									r.addChar(q);
								}
							}
						};
					}
				}
			};
			case TBool(b): if (b) r.addString("true"); else r.addString("false");
			case TNull: r.addString("undefined");
			case TThis: {
				#if (sfgml_keep_this_self == "force")
				r.addString("this");
				#else
				switch (selfLevel) {
					case 0: r.addString("self");
					case 1: r.addString("other");
					default: r.addString("this");
				}
				#end
			};
			default: Context.error("Can't print " + value.getName(), pos);
		}
	}
	
	private static var makeReserved_kw = SfGmlBuiltin.keywords.split(" ");
	private static var makeReserved_vars = SfGmlBuiltin.vars.split(" ");
	private static var makeReserved_fns = SfGmlBuiltin.functions.split(" ");
	private static function makeReserved(pre:String, isInst:Bool):Map<String, String> {
		var out = new Map();
		for (s in makeReserved_kw) out[s] = pre + s;
		if (!isInst) for (s in makeReserved_vars) out[s] = pre + s;
		for (s in makeReserved_fns) out[s] = pre + s;
		return out;
	}
	
	private static var getVarName_map:Map<String, String> = makeReserved("l_", false);
	override public function getVarName(name:String) {
		if (sfConfig.localPrefix == "") {
			var r = getVarName_map[name];
			return r != null ? r : name;
		} else return name;
	}
	
	private static var getFieldName_map:Map<String, String> = makeReserved("i_", true);
	public function getFieldName(name:String) {
		var p = sfConfig.fieldPrefix;
		if (p != "") return p + name;
		var r = getFieldName_map[name];
		return r != null ? r : name;
	}
	
	override public function printFormat(b:SfBuffer, fmt:String, v:Dynamic):Bool {
		switch (fmt) {
			case "type_auto": b.addTypePathAuto(v);
			case "type_dot": b.addTypePath(v, ".".code);
			case "field_auto": b.addFieldPathAuto(v);
			case "base_type": b.addBaseTypeName(v);
			case "hint": b.addHintString(v);
			case "+region": b.addHintFoldOpen(v);
			case "-region": b.addHintFoldClose(); return false;
			case "l_": b.addString(sfConfig.localPrefix); return false;
			case "var": b.addString(sfConfig.localPrefix); b.addString(v);
			default: return null;
		}
		return true;
	}
	//
	public var typeMetaPfx:String = "haxe_type";
	override function typeInit() {
		if (sfConfig.stdPack != null) {
			typeMetaPfx = sfConfig.stdPack + "_haxe_type";
		} else typeMetaPfx = "haxe_type";
		//
		typeArrayPath = "Array:array";
		typeStringPath = "String:string";
		var typeClassImpl = typeMap.get("Class", "Class_Impl_");
		if (typeClassImpl != null) typeClassImpl.isHidden = true;
		super.typeInit();
		// propagate object names to children:
		for (c in classList) if (c.objName == null) {
			var q = c.superClass;
			while (q != null) {
				var o = q.objName;
				if (o != null) {
					c.objName = o;
					c.dotAccess = true;
					break;
				} else q = q.superClass;
			}
		}
		for (a in abstractList) {
			if (a.meta.has(":std") && a.impl != null) a.impl.isStd = true;
		}
	}
	
	private var opt_Std_String:SfGml_Std_string = null;
	override function getPreproc():Array<SfOptImpl> {
		var r = super.getPreproc();
		var pre = [
			new SfGml_String_new(),
			#if sfgml_catch_error
			new SfGmlCatchError(),
			#end
			new SfGmlWith(),
			new SfOptIndexes(),
			new SfOptBinop(),
			new SfGmlObjectDecl(),
			new SfGml_Type_enumHelpers(),
			(opt_Std_String = new SfGml_Std_string()),
		]; pre.reverse(); for (o in pre) r.unshift(o);
		r.moveToFront(SfOptInstanceOf);
		r.insertAfter(SfOptFunc, new SfGmlLocalFunc());
		r.push(new SfGml_StdTypeImpl(false));
		r.unshift(new SfGml_ArrayImpl(false));
		return r;
	}
	override function getOptimizers():Array<SfOptImpl> {
		var r = super.getOptimizers();
		var c = sfConfig;
		if (c.analyzer) r.replace(SfOptAutoVar, new SfGmlAutoVar());
		r.push(new SfGmlRest());
		r.push(new SfGml_NativeString());
		r.push(new SfGmlArrayDecl());
		r.push(new SfGmlType());
		r.push(new SfGmlRepeat());
		r.push(new SfGmlArgs());
		r.push(new SfGmlArrayAccess());
		r.push(new SfGmlCFor());
		r.push(new SfGmlClosureField());
		r.push(new SfGml_ArrayImpl(true));
		r.push(new SfGmlCullHelpers());
		r.push(opt_Std_String);
		r.push(new SfGml_StdTypeImpl(true));
		return r;
	}
	
	/**
	 * -1: always use `this` local variable
	 * 0: `this` is `self`
	 * 1: `this` is `other`
	 * 2+: `this` is `this` local variable
	 */
	public var selfLevel:Int = -1;
	
	public var isInSwitchBlock:Bool = false;
	
	override public function printExpr(r:SfBuffer, expr:SfExpr, flags:SfPrintFlags):Void {
		if (flags == null) throw "Flags is null";
		inline function addExprs(_exprs:Array<SfExpr>, _flags:SfPrintFlags) {
			var _sep = false;
			for (_expr in _exprs) {
				if (_sep) r.addComma(); else _sep = true;
				printExpr(r, _expr, _flags);
			}
		}
		inline function addBlock(_stat:SfExpr) {
			r.addBlockOpen();
			r.addLine(1);
			r.addExpr(_stat, SfPrintFlags.StatWrap);
			r.addSemico();
			r.addLine( -1);
			r.addBlockClose();
		}
		inline function printVarType(v:SfVar):Void {
			if (sfConfig.hintVarTypes) {
				var s = SfGmlTypeHint.get(v.type);
				if (s != null) printf(r, "/*:%s*/", s);
			}
		}
		inline function error(e:SfExpr, s:String) {
			return e.error(s);
		}
		var i:Int, n:Int;
		var k:Int, l:Int;
		var s:String;
		var x:SfExpr;
		var sep:Bool, z:Bool;
		xt = expr;
		if (expr == null) {
			printf(r, "!null expr!");
			Context.warning("There's a null expr, shouldn't happen (check output for `!null expr!`)"
			+ haxe.CallStack.toString(haxe.CallStack.callStack()),
				haxe.macro.PositionTools.make({min:0, max:0, file:sfGenerator.outputPath}));
		}
		else switch (expr.def) {
			//{ identifiers and literals
			case SfConst(c): printConst(r, c, expr);
			case SfLocal(v): {
				printf(r, "%s%s", sfConfig.localPrefix, v.name);
			};
			case SfIdent(_name): r.addString(_name);
			case SfDynamic(_code, []): r.addString(_code);
			case SfDynamic(_code, _args): {
				if (_args.length >= 10) error(expr, "Too many arguments");
				var modWith = _code == SfGmlWith.withCode;
				var _isInSwitchBlock = isInSwitchBlock;
				if (modWith) {
					isInSwitchBlock = false;
					if (selfLevel >= 0) selfLevel++; else selfLevel--;
				}
				var start = 0;
				var cubAt = _code.indexOf("{");
				while (cubAt >= 0) {
					i = cubAt;
					k = _code.fastCodeAt(++i);
					var flags:SfPrintFlags = -1;
					if (k == "x".code) {
						flags = SfPrintFlags.ExprWrap;
						k = _code.fastCodeAt(++i);
					} else if (k == "s".code) {
						flags = SfPrintFlags.Stat;
						k = _code.fastCodeAt(++i);
					} else if (k == "b".code) {
						flags = SfPrintFlags.StatWrap;
						k = _code.fastCodeAt(++i);
					} 
					if (k >= "0".code && k <= "9".code && _code.fastCodeAt(++i) == "}".code) {
						if (flags == -1) flags = sf.gml.SfGmlTools.isInline(_code, cubAt)
							? SfPrintFlags.ExprWrap : SfPrintFlags.Stat;
						r.addSub(_code, start, cubAt - start);
						r.addExpr(_args[k - "0".code], flags);
						start = ++i;
					}
					cubAt = _code.indexOf("{", i);
				}
				r.addSub(_code, start);
				if (modWith) {
					isInSwitchBlock = _isInSwitchBlock;
					if (selfLevel >= 0) selfLevel--; else selfLevel++;
				}
			};
			case SfArrayDecl(vals): {
				r.addChar("[".code);
				for (i in 0 ... vals.length) {
					if (i > 0) r.addComma();
					r.addExpr(vals[i], SfPrintFlags.ExprWrap);
				}
				r.addChar("]".code);
			};
			case SfObjectDecl(pairs): {
				if (sfConfig.modern) {
					var lineSep = pairs.length > 3;
					if (lineSep) {
						printf(r, "{%(+\n)");
					} else {
						printf(r, "{`");
						r.indent++;
					}
					for (i in 0 ... pairs.length) {
						if (i > 0) {
							if (lineSep) {
								printf(r, ",\n");
							} else r.addComma();
						}
						printf(r, "%s:`", pairs[i].name);
						r.addExpr(pairs[i].expr, SfPrintFlags.ExprWrap);
					}
					if (lineSep) {
						printf(r, "%(-\n)}");
					} else {
						r.indent--;
						if (pairs.length > 0) r.addSep();
						printf(r, "}");
					}
				} else {
					expr.error("Anonymous object literals are only supported in >= 2.3."
						+ " If this is an array-object, try assigning into a typed variable");
				}
			};
			case SfTypeExpr(t): {
				if (Std.is(t, SfEnum)) {
					var e:SfEnum = cast t;
					if (e.isFake) expr.error("Can't reference a fake enum.");
				} else if (t.isExtern
					&& t != typeArray
					&& t.module != "js.lib.Error"
				) {
					expr.error("Can't reference an extern class.");
				}
				r.addString("mt_");
				r.addTypePath(t, "_".code);
			};
			case SfFunction(fn): {
				if (sfConfig.modern) {
					if (flags.isStat()) printf(r, "var %s%s`=`", sfConfig.localPrefix, fn.name);
					printf(r, "function");
					// if (fn.name != null) printf(r, " %s", fn.name); // assigns into self, very bad
					printf(r, "(");
					r.addArguments(fn.args);
					printf(r, ")`");
					if (!fn.expr.isEmpty()) {
						printf(r, "{%(+\n)");
						var flags:SfArgVarsExt = 0;
						var cf = currentField;
						if (cf != null && cf.isInst && cf.isStructField) {
							flags |= SfArgVarsExt.ThisSelf;
						}
						var _isInSwitchBlock = isInSwitchBlock;
						isInSwitchBlock = false;
						SfArgVars.printExt(r, fn.expr, fn.args, flags);
						isInSwitchBlock = _isInSwitchBlock;
						r.addExpr(fn.expr, SfPrintFlags.StatWrap);
						printf(r, "%(-\n)}");
					} else printf(r, "{}");
				} else {
					expr.error("Can't print function literals pre-2.3");
				}
			};
			//}
			
			//{ array/field access
			case SfArrayAccess(a, i): printf(r, "%x[%x]", a, i);
			case SfEnumAccess(a, e, i): {
				if (e.isStruct) {
					switch (i.def) {
						case SfConst(TInt(0)): printf(r, "%x.__enumIndex__", a);
						default: {
							a.error("Can't array access non-index item of struct-enum");
						};
					}
				} else {
					printf(r, "%x[%x]", a, i);
				}
			};
			case SfEnumParameter(_expr, _ctr, _index): {
				if (_ctr.isStructField) {
					if (_index >= 0) {
						printf(r, "%x.%s", _expr, _ctr.args[_index].v.name);
					} else {
						printf(r, "%x.__enumIndex__", _expr);
					}
				} else {
					printf(r, "%x[%d]", _expr, _index + 1);
				}
			};
			case SfInstField(_inst, _field): {
				if (_field.dotAccess) {
					printf(r, "%x.%s", _inst, _field.name);
				} else {
					i = _field.index;
					if (i >= 0) {
						printf(r, "%x[%d%(hint)]", _inst, i, _field.name);
					} else expr.error("Field " + _field.name + " has no index.");
				}
			};
			case SfStaticField(c, f): {
				if (c.dotStatic) {
					if (currentClass == c
						&& currentField != null
						&& currentField.needsMethodClosure()
					) {
						switch (selfLevel) {
							case -1: r.addString("self.");
							case -2: r.addString("other.");
							default: printf(r, "%type_auto.", c);
						}
						r.addString(f.name);
					} else {
						printf(r, "%(type_auto).%s", c, f.name);
					}
				} else if (f.isVar && !c.isStd) {
					if (!sfConfig.modern) r.addString("g_");
					r.addFieldPathAuto(f);
				} else {
					#if (1) // assume extension script IDs cursed till further notice
					if (SfGmlScriptRefs.enabled && !f.isVar && !(c.isHidden || c.isExtern)) {
						printf(r, 'f_');
						r.addFieldPathAuto(f);
					} else r.addFieldPathAuto(f);
					#elseif (sfgml_script_lookup)
					if (!f.isVar) {
						printf(r, '%s("', sfConfig.scriptLookup);
						r.addFieldPathAuto(f);
						printf(r, '")');
					} else r.addFieldPathAuto(f);
					#else
					r.addFieldPathAuto(f);
					#end
				}
			}
			case SfEnumField(_enum, _ctr): { // Enum.Ctr
				if (_enum.noRef) {
					r.addFieldPath(_ctr, "_".code, "_".code);
					r.add("()");
				} else if (_enum.isFake) {
					if (_enum.nativeGen) {
						if (sfConfig.gmxMode) {
							r.addFieldPath(_ctr, "_".code, "_".code);
						} else printf(r, "%(type_auto).%s", _enum, _ctr.name);
					} else if (_enum.isExtern) {
						r.addFieldPath(_ctr, "_".code, "_".code);
					} else {
						r.addInt(_ctr.index);
						if (sfConfig.hint) {
							r.addHintOpen();
							printf(r, "%s.%s", _enum.name, _ctr.name);
							r.addHintClose();
						}
					}
				} else {
					if (sfConfig.gmxMode) r.addString("g_");
					r.addFieldPath(_ctr, "_".code, "_".code);
				}
			};
			case SfDynamicField(obj, _field): {
				z = true;
				switch (obj.def) {
					case SfTypeExpr(t): {
						if (Std.is(t, SfClass)) {
							var fd = (cast t:SfClass).fieldMap[_field];
							if (fd != null) {
								r.addFieldPathAuto(fd);
								z = false;
							}
						}
					};
					default:
				}
				if (z) {
					var t = obj.getTypeNz();
					switch (t) {
						case TAbstract(_.get() => at, _): t = at.type;
						default:
					}
					switch (t) {
						case TType(_.get() => dt, _): {
							var at = anonMap.baseGet(dt);
							if (at != null) {
								s = _field;
								if (at.isDsMap) {
									var fd = at.fieldMap[s];
									if (fd != null) s = fd.name;
									printf(r, '%x[?"%s"]', obj, s);
									z = false;
								} else if (at.dotAccess) {
									printf(r, '%x.%s', obj, s);
									z = false;
								} else if (at.indexMap.exists(s)) {
									printf(r, "%x[", obj);
									at.printAnonFieldTo(r, s, at.indexMap[s]);
									printf(r, "]");
									z = false;
								}
							}
						};
						case TInst(_.get() => ct, _): {
							var ct = classMap.baseGet(ct);
							if (ct != null && ct.dotAccess) {
								printf(r, "%x.%s", obj, _field);
								z = false;
							}
						};
						default:
					}
				}
				if (z) {
					if (sfConfig.modern) {
						printf(r, "%x.%s", obj, _field);
					} else {
						expr.error("[SfGenerator:printExpr] Can't do dynamic field read for `" + _field + "` from `" + obj.dump() + "` (" + obj.getName() + "," + obj.getTypeNz() + ")");
					}
				}
			};
			//}
			
			//{ operators
			case SfBinop(o = OpAssign | OpAssignOp(_), _.def => SfInstField(q, f), v): {
				if (f.parentClass.dotAccess) {
					printf(r, "%x.%s", q, f.name);
					printSetOp(r, o, expr);
					printf(r, "%x", v);
				} else {
					i = f.index;
					if (i >= 0) {
						printf(r, "%x[@%d%(hint)]", q, i, f.name);
						printSetOp(r, o, expr);
						printf(r, "%x", v);
					} else expr.error("Field " + f.name + " has no index.");
				}
			};
			case SfBinop(o = OpAssign | OpAssignOp(_), _.def => SfDynamicField(q, f), v): {
				z = true;
				switch (q.getTypeNz()) {
					case TType(_.get() => dt, _): {
						var at = anonMap.baseGet(dt);
						if (at != null) {
							s = f;
							if (at.isDsMap) {
								var fd = at.fieldMap[s];
								if (fd != null) s = fd.name;
								printf(r, '%x[?"%s"]', q, s);
								z = false;
							} else if (at.dotAccess) {
								printf(r, '%x.%s', q, s);
								z = false;
							} else if (at.indexMap.exists(s)) {
								printf(r, "%x[@", q);
								at.printAnonFieldTo(r, s, at.indexMap[s]);
								printf(r, "]");
								z = false;
							}
							if (!z) {
								printSetOp(r, o, expr);
								r.addExpr(v, SfPrintFlags.ExprWrap);
							}
						}
					};
					case TInst(_.get() => ct, _): {
						var ct = classMap.baseGet(ct);
						if (ct != null && ct.dotAccess) {
							printf(r, "%x.%s", q, f);
							printSetOp(r, o, expr);
							r.addExpr(v, SfPrintFlags.ExprWrap);
							z = false;
						}
					};
					default:
				}
				if (z) {
					if (sfConfig.modern) {
						printf(r, "%x.%s", q, f);
						printSetOp(r, o, expr);
						r.addExpr(v, SfPrintFlags.ExprWrap);
					} else {
						expr.error("[SfGenerator:printExpr] Can't do dynamic field write on "
							+ SfExprTools.dump(expr) + " type " + q.getType());
					}
				}
			};
			case SfBinop(o = OpAssign | OpAssignOp(_), _.def => SfArrayAccess(a, i), v): {
				switch (a.def) {
					case SfInstField(_, f) | SfStaticField(_, f) if (f.noRefWrite): {
						printf(r, "%x[%x]", a, i);
					};
					default: printf(r, "%x[@%x]", a, i);
				}
				printSetOp(r, o, expr);
				printf(r, "%x", v);
			};
			case SfBinop(OpUShr, a, b): { // a >>> b
				switch (b.def) {
					case SfConst(TInt(0)): printf(r, "(%x & $FFFFFFFF)", a);
					default: printf(r, "((%x & $FFFFFFFF) >> %x)", a, b);
				}
			};
			case SfBinop(o = OpAssign | OpAssignOp(_), a, b): { // a @ b
				if (flags.isInline()) {
					switch (b.unpack().def) {
						case SfConst(TInt(1)): {
							switch (o) {
								case OpAssignOp(OpAdd): printf(r, "++");
								case OpAssignOp(OpSub): printf(r, "--");
								default: expr.error("Inline assignment: " + expr.def);
							}
							r.addExpr(a, SfPrintFlags.Inline);
						};
						default: expr.error("Inline assignment: " + expr.def);
					}
				} else {
					r.addExpr(a, SfPrintFlags.Inline);
					printSetOp(r, o, expr);
					r.addExpr(b, SfPrintFlags.Inline);
				}
			};
			case SfBinop(o, a, b): { // a @ b
				r.addExpr(a, flags);
				printBinOp(r, o, expr);
				r.addExpr(b, flags);
			};
			case SfUnop(o = OpIncrement | OpDecrement, _postFix, x): { // ++\--
				z = (o == OpIncrement);
				if (flags.isStat()) {
					if (sfConfig.avoidPostfixStatements) {
						_postFix = false;
					} else if (sfConfig.avoidPrefixStatements) {
						_postFix = true;
					}
				}
				if (!_postFix) r.addString(z ? "++" : "--");
				switch (x.def) {
					case SfInstField(q, f): {
						if (f.dotAccess) {
							printf(r, "%x.%s", q, f.name);
						} else if ((i = f.index) >= 0) {
							printf(r, "%x[@%d%(hint)]", q, i, f.name);
						} else expr.error("Field " + f.name + " has no index.");
					}
					case SfArrayAccess(a, i): {
						switch (a.def) {
							case SfInstField(_, f) | SfStaticField(_, f)
							if (f.noRefWrite): printf(r, "%x[%x]", a, i);
							default: printf(r, "%x[@%x]", a, i);
						}
					};
					default: r.addExpr(x, SfPrintFlags.Inline);
				}
				if (_postFix) r.addString(z ? "++" : "--");
			};
			case SfUnop(_op, _postFix, _expr): {
				if (flags.isInline()) {
					if (_postFix) r.addExpr(_expr, SfPrintFlags.Inline);
					switch (_op) {
						case OpIncrement: r.addChar2("+".code, "+".code);
						case OpDecrement: r.addChar2("-".code, "-".code);
						case OpNot: r.addChar("!".code);
						case OpNeg: r.addChar("-".code);
						case OpNegBits: r.addChar("~".code);
					};
					if (!_postFix) r.addExpr(_expr, SfPrintFlags.Inline);
				} else {
					expr.error("Can't apply " + _op.getName() + " here.");
				}
			};
			//}
			
			//{ calls
			case SfCall(x, _args): { // func(...args)
				n = _args.length;
				sep = false;
				/** |1: print expr, |2: print `(`, <0: print nothing */
				var callFlags = 2;
				
				// if we are calling a field that's being wget, we need to resolve that
				// this is asking for a refactor of some sort
				var selfExpr:SfExpr = null;
				if (!sfConfig.hasChainedAccessors) switch (x.def) {
					case SfCall(
						_.def => SfInstField(self, field),
						[_.def => SfConst(TInt(i))]
					) if (field == SfGmlArrayAccess.wget && i >= 0): {
						switch (self.followType()) {
							case TInst(_.get() => c, _): {
								var sfc = classMap.baseGet(c);
								if (sfc != null) {
									var sfd = sfc.fieldsByIndex[i];
									if (sfd != null && sfd.callNeedsThis) {
										selfExpr = self;
									}
								}
							};
							default:
						}
					};
					default:
				}
				//
				switch (x.unpack().def) {
					case SfIdent(name): r.addString(name);
					case SfDynamic(code, []): { // arbitrary code
						if (!sfConfig.modern && code.charCodeAt(code.length - 1) == "]".code) {
							// if we are trying to call dynamic `arr[x]`,
							// we need script_execute around it in pre-2.3
							callFlags = 3;
						} else r.addString(code);
					};
					case SfConst(TSuper): { // super(...constructor args)
						if (currentClass == null) {
							expr.error("Trying to call super outside of a class");
						}
						var superClass = this.currentClass.superClass;
						if (superClass.isStruct) {
							printf(r, "method(%const, %(field_auto))", TThis, superClass.constructor);
						} else {
							printf(r, "%(field_auto)(this", superClass.constructor);
							callFlags = 0; sep = true;
						}
					};
					case SfInstField(_.def => SfConst(TSuper), _field): { // super.method(...)
						if (_field.parentClass.dotAccess && sfConfig.modern) {
							printf(r, "method(%const, %(field_auto))", TThis, _field);
						} else {
							printf(r, "%(field_auto)(this", _field);
							callFlags = 0; sep = true;
						}
					};
					case SfStaticField(cl, fd): { // Type.func(...)
						if (fd.name == "set_2D" && fd.parentType.realPath == "gml.NativeArray"
							&& _args[0].def.match(SfLocal(_) | SfStaticField(_, _))
						) { // NativeArray.set2D(a, b, c, d) -> a[@b, c] = d;
							printf(r, "%x[@%x,`%x]`=`%x", _args[0], _args[1], _args[2], _args[3]);
							return;
						} else if (cl.dotStatic || !fd.isVar || fd.meta.has(":script")) {
							r.addFieldPathAuto(fd);
						} else callFlags = 3;
					};
					case SfDynamicField(_inst, _field): { // typedef.field(...)
						if (sfConfig.modern) {
							callFlags = 3;
						} else {
							if (!_inst.isSimple()) {
								_inst.warning("This call may have side effects.");
							}
							printf(r, "script_execute(%x,`%x", x, _inst);
							callFlags = 0; sep = true;
						}
					};
					case SfInstField(_inst, _field): {
						k = _field.index;
						if (k >= 0) { // inst.dynMethod(...)
							if (_field.callNeedsThis) {
								if (!_inst.isSimple()) {
									_inst.warning("This call may have side effects.");
								}
								printf(r, "script_execute(%x,`%x", x, _inst);
							} else printf(r, "script_execute(%x", x);
							sep = true;
							callFlags = 0;
						} else if (sfConfig.modern
							&& _field.parentClass.dotAccess
							&& !(_field.parentClass.isExtern && _field.exposePath != null)
						) {
							printf(r, "%x.%s", _inst, _field.name);
						} else {
							k = 0;
							#if !sfgml_no_accessors
							switch (_field.parentType.name) {
								case "ds_list": switch (_field.name) {
									case "find_value": k = 1;
									case "set": k = 2;
								};
								case "ds_map": switch (_field.name) {
									case "find_value": k = 3;
									case "set": k = 4;
								};
								case "ds_grid": switch (_field.name) {
									case "get": k = 5;
									case "set": k = 6;
								};
							}
							#end
							if (k <= 0) {
								//
							} else if (sfConfig.hasChainedAccessors
								|| _inst.unpack().def.match(SfLocal(_) | SfStaticField(_, _))
							) {
								switch (k) {
									case 1: printf(r, "%x[|%x]", _inst, _args[0]);
									case 2: printf(r, "%x[|%x]`=`%x", _inst, _args[0], _args[1]);
									case 3: printf(r, "%x[?%x]", _inst, _args[0]);
									case 4: printf(r, "%x[?%x]`=`%x", _inst, _args[0], _args[1]);
									case 5: printf(r, "%x[#%x,`%x]", _inst, _args[0], _args[1]);
									case 6: printf(r, "%x[#%x,`%x]`=`%x", _inst,
										_args[0], _args[1], _args[2]);
								};
								return;
							} else k = 0;
							r.addFieldPathAuto(_field);
							printf(r, "(%x", _inst);
							sep = true;
							callFlags = 0;
						}
					};
					case SfEnumField(_enum, _field): {
						if (_enum.isPureArray()) {
							printf(r, "[");
							if (_enum.hasNativeEnum()) {
								r.addFieldPath(_field, "_".code, ".".code);
							} else {
								printf(r, "%d", _field.index);
								if (sfConfig.hint) {
									r.addHintOpen();
									printf(r, "%s.%s", _enum.name, _field.name);
									r.addHintClose();
								}
							}
							i = 0; while (i < n) printf(r, ",`%x", _args[i++]);
							n = _field.args.length;
							while (i++ < n) printf(r, ",`undefined");
							printf(r, "]");
							return;
						}
						r.addFieldPathAuto(_field);
						callFlags = 2;
					};
					default: callFlags = 3;
				}
				if (callFlags & 3 == 3) {
					if (sfConfig.modern) {
						printf(r, "%x(", x);
					} else {
						printf(r, "script_execute(");
						printf(r, "%x", x);
						if (selfExpr != null) {
							if (!selfExpr.isSimple()) {
								selfExpr.warning("This call may have side effects.");
							}
							printf(r, ", %x", selfExpr);
						}
						sep = true;
					}
				} else if (callFlags & 2 != 0) r.addParOpen();
				//
				if (callFlags >= 0) {
					i = 0; while (i < n) {
						if (sep) r.addComma(); else sep = true;
						r.addExpr(_args[i], SfPrintFlags.ExprWrap);
						i += 1;
					}
					r.addParClose();
				}
			};
			case SfTrace(td, w): { // trace(...args)
				r.addString(sfConfig.traceFunc);
				r.addParOpen();
				printf(r, '"%s:%d:",`', td.fileName, td.lineNumber);
				n = w.length;
				i = 0; while (i < n) {
					if (i > 0) r.addComma();
					r.addExpr(w[i], SfPrintFlags.ExprWrap);
					i += 1;
				}
				r.addParClose();
			};
			case SfNew(t, _, m): {
				if (t.isStruct) {
					printf(r, "new %(type_auto)", t);
				} else {
					var ctr:SfClassField = t.constructor;
					if (ctr != null) {
						s = ctr.metaString(":expose");
						if (s != null) {
							r.addString(s);
							s = null;
						} else {
							s = ctr.metaString(":native");
							if (s == null) s = "create";
						}
					} else s = "create";
					if (s != null) {
						l = r.length;
						r.addTypePathAuto(t);
						if (r.length > l) r.addChar("_".code);
						r.addString(s);
					}
				}
				r.addParOpen();
				addExprs(m, SfPrintFlags.ExprWrap);
				r.addParClose();
			};
			//}
			
			case SfVarDecl(v, z, x): { // var v = x
				printf(r, "var %s%s", sfConfig.localPrefix, v.name);
				printVarType(v);
				if (z) printf(r, "`=`%x", x);
			};
			case SfBlock(_exprs): { // { ...exprs }
				if (flags.isInline()) {
					error(expr, "Inline block: " + expr.dump());
				} else if (flags.needsWrap()) {
					if (_exprs.length != 1) {
						r.addBlockOpen();
						if (_exprs.length > 0) {
							r.addLine(1);
							r.addExpr(expr, SfPrintFlags.StatWrap);
							r.addLine( -1);
						} else r.addSep();
						r.addBlockClose();
					} else r.addExpr(_exprs[0], SfPrintFlags.Stat);
				} else {
					n = _exprs.length;
					i = 0; while (i < n) {
						x = _exprs[i++];
						if (!x.isEmpty()) {
							if (sep) r.addLine();
							#if (sfgml_traceline)
							ematch(x, SfBlock(_), { }, {
								printf(r, 'traceline("%z");\n', SfDump.pos(x.getPos(), r));
							});
							#end
							l = r.length;
							switch (x.def) {
								case SfVarDecl(v, false, _): {
									// Join value-less variable declarations
									printf(r, "var %s%s", sfConfig.localPrefix, v.name);
									printVarType(v);
									while (i < n) switch (_exprs[i].def) {
										case SfVarDecl(v1, false, _): {
											printf(r, ",`%s%s", sfConfig.localPrefix, v1.name);
											printVarType(v1);
											i += 1;
											continue;
										};
										default: break;
									}
								};
								default: r.addExpr(x, SfPrintFlags.StatWrap);
							}
							sep = r.length > l;
							if (sep) r.addSemico();
						}
					}
				}
			};
			//{ branching
			case SfIf(c, a, z, b): { // if (c) a else b
				if (flags.isInline()) {
					if (sfConfig.ternary) {
						if (z) {
							printf(r, "(%x`?`%x`:`%x)", c.unpack(), a, b);
						} else error(expr, "Inline single-branch if..?");
					} else error(expr, "Can't print an inline if-block.");
				} else printIf(r, c, a, b, true);
			};
			case SfWhile(_cond, _expr, _normal): {
				var _isInSwitchBlock = isInSwitchBlock;
				isInSwitchBlock = false;
				if (_normal) {
					printf(r, "while`%x`", _cond);
				} else r.addString("do ");
				r.addBlockExpr(_expr);
				if (!_normal) printf(r, " until`(%x)", _cond.invert());
				isInSwitchBlock = _isInSwitchBlock;
			};
			case SfCFor(q, c, p, x): {
				printf(r, "for`(");
				var _isInSwitchBlock = isInSwitchBlock;
				isInSwitchBlock = false;
				switch (q.def) {
					case SfBlock([]): r.addString(";");
					default: printf(r, "%sx;", q);
				}
				printf(r, "`%x;`%sx)`", c.unpack(), p);
				addBlock(x);
				isInSwitchBlock = _isInSwitchBlock;
			};
			case SfSwitch(_expr, _cases, _, _default): {
				printSwitch(r, _expr, _cases, _default);
			};
			case SfReturn(z, x): { // return x
				r.addString("return ");
				#if (sfgml_tracecall)
				printf(r, 'tracecall("- %field_auto",`', currentField);
				#end
				if (z) {
					r.addExpr(x, SfPrintFlags.ExprWrap);
				} else r.addString("0");
				#if (sfgml_tracecall)
				printf(r, ")");
				#end
			}
			case SfBreak: {
				if (isInSwitchBlock) expr.warning("GML does not support nested break - this will only break out of a switch-block");
				r.addString("break");
			};
			case SfContinue: r.addString("continue");
			case SfTry(block, catches): {
				if (sfConfig.hasTryCatch) {
					if (catches.length > 1) {
						catches[1].expr.error("Only 1-catch blocks are supported at this time.");
					}
					printf(r, "try`{%(+\n)");
					r.addExpr(block, SfPrintFlags.StatWrap);
					var c = catches[0];
					printf(r, "%(-\n)}`catch`(%var)`{%(+\n)", c.v.name);
					r.addExpr(c.expr, SfPrintFlags.StatWrap);
					printf(r, "%(-\n)}");
				} else expr.error("try-catch is only supported in GMS>=2.3");
			};
			case SfThrow(x): {
				switch (x.def) {
					case SfNew(c, _, [v]) if (c.name == "HaxeError"): x = v;
					default:
				}
				if (sfConfig.hasTryCatch) {
					printf(r, "throw %x", x);
				} else {
					printf(r, "show_error(%x,`false)", x);
				}
			};
			//}
			//{ other wrappers
			case SfParenthesis(x): printf(r, "(%x)", x);
			case SfCast(x, _): r.addExpr(x, flags);
			case SfMeta(m, x): r.addExpr(x, flags);
			//}
			default: error(expr, "Can't print " + expr.getName());
		} // switch (expr), can return
	}
	
	private inline function printAssignOp(r:SfBuffer, op:Binop, ?ctx:SfExpr) {
		switch (op) {
			case OpAdd: r.addSepChar2("+".code, "=".code);
			case OpSub: r.addSepChar2("-".code, "=".code);
			case OpMult: r.addSepChar2("*".code, "=".code);
			case OpDiv: r.addSepChar2("/".code, "=".code);
			case OpMod: r.addSepChar2("%".code, "=".code);
			case OpAnd: r.addSepChar2("&".code, "=".code);
			case OpOr: r.addSepChar2("|".code, "=".code);
			case OpXor: r.addSepChar2("^".code, "=".code);
			default: {
				var et = "Assignment operator " + op + "is not supported.";
				if (ctx != null) {
					ctx.error(et);
				} else throw et;
			}
		}
	}
	
	private function printBinOp(r:SfBuffer, op:Binop, ?ctx:SfExpr) {
		switch (op) {
			case OpAdd: r.addSepChar("+".code);
			case OpMult: r.addSepChar("*".code);
			case OpDiv: r.addSepChar("/".code);
			case OpAssign: r.addSepChar("=".code);
			case OpSub: r.addSepChar("-".code);
			case OpEq: r.addSepChar2("=".code, "=".code);
			case OpNotEq: r.addSepChar2("!".code, "=".code);
			case OpGt: r.addSepChar(">".code);
			case OpGte: r.addSepChar2(">".code, "=".code);
			case OpLt: r.addSepChar("<".code);
			case OpLte: r.addSepChar2("<".code, "=".code);
			case OpBoolAnd: r.addSepChar2("&".code, "&".code);
			case OpBoolOr: r.addSepChar2("|".code, "|".code);
			case OpMod: r.addSepChar("%".code);
			//
			case OpAnd: r.addSepChar("&".code);
			case OpOr: r.addSepChar("|".code);
			case OpXor: r.addSepChar("^".code);
			case OpShl: r.addSepChar2("<".code, "<".code);
			case OpShr: r.addSepChar2(">".code, ">".code);
			case OpUShr: r.addSepChar2(">".code, ">".code);
			//
			case OpAssignOp(o): printAssignOp(r, o, ctx);
			default: {
				var et = "Operator " + op + " is not supported.";
				if (ctx != null) {
					ctx.error(et);
				} else throw et;
			}
		}
	}
	
	private inline function printSetOp(r:SfBuffer, op:Binop, ?ctx:SfExpr) {
		switch (op) {
			case OpAssignOp(o): printAssignOp(r, o, ctx);
			case OpAssign: r.addSepChar("=".code);
			default: {
				var et = "Expected an assignment operator.";
				if (ctx != null) {
					ctx.error(et);
				} else throw et;
			};
		}
	}
	
	private inline function printIf(r:SfBuffer, c:SfExpr, t:SfExpr, x:SfExpr, small:Bool):Void {
		if (sfConfig.hint) switch (c.def) {
			case SfParenthesis(_.def => SfBinop(o,
				a = _.def => SfEnumAccess(_, e, _.def => SfConst(TInt(0))),
				b = _.def => SfConst(TInt(i))
			)): { // `if (adt[0] == 1)` -> `if (/* type */adt[0] == 1/* ctrName */)`
				printf(r, "if`(%x", a);
				r.addHintOpen();
				r.addTypePathAuto(e);
				r.addHintClose();
				printBinOp(r, o, c);
				r.addExpr(b, SfPrintFlags.ExprWrap);
				var sfc = e.indexMap[i];
				if (sfc != null) r.addHintString(e.indexMap[i].name);
				printf(r, ")`");
			};
			default: printf(r, "if`%x`", c);
		} else printf(r, "if`%x`", c);
		if (small) switch (t.unpack().def) {
			case SfIf(_, _, _): small = false;
			default:
		}
		if (small && x != null) switch (x.def) {
			case SfIf(_, _, _): small = false;
			default: if (!x.isSmall()) small = false;
		}
		if (small) r.addExpr(t, SfPrintFlags.Stat); else r.addBlockExpr(t);
		if (x != null) {
			printf(r, "; else ");
			switch (x.def) {
				case SfIf(c, t, z, x): printIf(r, c, t, x, false);
				default: r.addExpr(x, SfPrintFlags.Stat);
			}
		}
	}
	
	private inline function printSwitch(r:SfBuffer, expr:SfExpr, cw:Array<SfExprCase>, cd:SfExpr) {
		var z:Bool;
		// enum data (if sf-hint is set):
		var expru = expr.unpack();
		var em = null, e:SfEnum;
		var nativeEnum = false;
		switch (expru.def) {
			case SfEnumAccess(_, et, _.def => SfConst(TInt(0))): e = et;
			default: switch (expru.getType()) {
				case TEnum(_.get() => et, _): e = sfGenerator.enumMap.baseGet(et);
				default: e = null;
			}
		};
		if (e != null) {
			em = e.indexMap;
			nativeEnum = e.hasNativeEnum();
		}
		//
		var hint = sfConfig.hint;
		printf(r, "switch`(%x", expru);
		if (e != null && !nativeEnum && hint) {
			r.addHintOpen();
			r.addTypePathAuto(e);
			r.addHintClose();
		}
		printf(r, ")`{");
		r.addLine(1);
		//
		var trail = false;
		var _isInSwitchBlock = isInSwitchBlock;
		isInSwitchBlock = true;
		for (cc in cw) {
			if (trail) r.addLine(); else trail = true;
			// "case v1: case v2:"
			var cv = cc.values;
			for (k in 0 ... cv.length) {
				if (k > 0) r.addSep();
				r.addString("case ");
				var v = cv[k];
				if (nativeEnum) switch (v.def) {
					case SfConst(TInt(i)) if (em[i] != null): {
						printf(r, "%(type_auto).%s", e, em[i].name);
					};
					default: r.addExpr(v, SfPrintFlags.ExprWrap);
				} else {
					r.addExpr(v, SfPrintFlags.ExprWrap);
					if (e != null) switch (v.def) {
						case SfConst(TInt(i)): {
							i |= 0; // neko bug?
							var sfc = em[i];
							r.addHintString(sfc != null ? sfc.name : "?");
						}
						default: 
					}
				}
				r.addChar(":".code);
			};
			// "$expr;"
			var x = cc.expr;
			z = x.isEmpty() ? null : !x.isSmall();
			if (z != null) {
				if (z) r.addLine(1); else r.addSep();
				r.addExpr(x, SfPrintFlags.StatWrap);
				r.addSemico();
			}
			if (!x.endsWithExits()) {
				if (z) r.addLine(0); else r.addSep();
				r.addString("break");
				r.addSemico();
			}
			if (z) r.indent--;
		} // for cases
		if (cd != null) {
			if (!cd.isEmpty()) {
				printf(r, "\ndefault:");
				z = !cd.isSmall();
				if (z) r.addLine(1); else r.addSep();
				r.addExpr(cd, SfPrintFlags.StatWrap);
				r.addSemico();
				if (z) r.indent -= 1;
			}
		}
		r.addLine(-1);
		r.addBlockClose();
		isInSwitchBlock = _isInSwitchBlock;
	}
	
}
