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
import sf.opt.*;
import sf.type.*;
import sf.type.expr.*;
import sf.type.expr.*;
import sf.type.SfTypeMap;
import sf.type.expr.SfExprDef.*;
import sf.type.expr.SfExpr;
import SfTools.*;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGenerator extends SfGeneratorImpl {
	
	public static function main() {
		SfConfig.main();
	}
	
	var startTime:Float = Sys.time();
	public function new() {
		super();
		Compiler.addClassPath(Context.resolvePath("gml/std"));
	}
	
	private function printTypeGrid(init:SfBuffer) {
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
			sfConfig.gmxMode = true;
			sfConfig.update();
			SfGmxGen.run(path);
			return;
		}
		if (StringTools.endsWith(path.toLowerCase(), ".yy")) {
			sfConfig.next = true;
			sfConfig.gmxMode = true;
			sfConfig.update();
			SfYyGen.run(path);
			return;
		}
		//
		var next = sfConfig.next;
		var hasArrayDecl = sfConfig.hasArrayDecl;
		(new SfGmlSnakeCase()).apply();
		//
		var mixed:SfBuffer = new SfBuffer();
		var out:SfBuffer = new SfBuffer();
		var init:SfBuffer = new SfBuffer();
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
		if (sfConfig.entrypoint != "") printf(mixed, "#define %s\n", sfConfig.entrypoint);
		var cond = sfConfig.printIf;
		//if (cond != null) printf(init, "if (%s) {\n", cond);
		//
		if (sfConfig.header != null) {
			for (line in sfConfig.header.split("\\n")) printf(mixed, "// %s\n", line);
		}
		if (SfGmlInstanceOf.isUsed) printTypeGrid(init);
		if (SfGmlEnumCtr.code != "") {
			if (hintFolds) printf(init, "//{ enum names\n");
			init.addString(SfGmlEnumCtr.code);
			if (hintFolds) printf(init, "//}\n");
		}
		//
		if (SfGmlType.usesProto) SfGmlTypeInit.printProto(init);
		if (true) SfGmlScriptRefs.main(init);
		if (SfGmlType.usesType) SfGmlTypeInit.printMeta(init);
		
		// generate class inits:
		for (c in classList) if (!SfExprTools.isEmpty(c.init)) {
			var len = init.length;
			init.addExpr(c.init, false);
			if (init.length > len) {
				init.addSemico();
				init.addLine();
			}
		}
		
		// generate static field init and the entrypoint call:
		for (t in typeList) {
			t.printTo(out, init);
		}
		if (mainExpr != null) {
			init.addExpr(mainExpr, false);
			init.addSemico();
			init.addLine();
		}
		//if (cond != null) printf(init, "}\n");
		// print header and save:
		if (sfConfig.timestamp) printf(mixed, "// Generated at %s (%dms) for v%s+\n",
			Date.now().toString(), Std.int((Sys.time() - startTime) * 1000), sfConfig.version);
		mixed.addBuffer(init);
		mixed.addBuffer(out);
		var mixedStr = mixed.toString();
		if (!sfConfig.timestamp && sfConfig.entrypoint == "" && mainExpr.isEmpty()) {
			mixedStr = StringTools.ltrim(mixedStr);
		}
		sys.io.File.saveContent(path, mixedStr);
	}
	
	override public function compile(apiTypes:Array<haxe.macro.Type>, apiMain:Null<TypedExpr>, outputPath:String) {
		//
		var op = outputPath;
		inline function extLq(path:String):String {
			return Path.extension(path).toLowerCase();
		}
		if (extLq(op) == "_") op = Path.withoutExtension(op);
		switch (extLq(op)) {
			case "gmx" if (extLq(Path.withoutExtension(op)) == "extension"): {
				sfConfig.gmxMode = true;
				sfConfig.update();
			};
			case "yy": {
				sfConfig.next = true;
				sfConfig.gmxMode = true;
				sfConfig.update();
			};
		}
		//
		super.compile(apiTypes, apiMain, outputPath);
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
			case TThis: r.addString("this");
			default: Context.error("Can't print " + value.getName(), pos);
		}
	}
	
	private static var reserved:Map<String, String> = {
		var out = new Map();
		for (kw in SfGmlBuiltin.keywords.split(" ")) out.set(kw, "var_" + kw);
		for (kw in SfGmlBuiltin.vars.split(" ")) out.set(kw, "var_" + kw);
		for (kw in SfGmlBuiltin.functions.split(" ")) out.set(kw, "var_" + kw);
		out;
	};
	override public function getVarName(name:String) {
		if (sfConfig.localPrefix == "") {
			var r = reserved[name];
			return r != null ? r : name;
		} else return name;
	}
	override public function printFormat(b:SfBuffer, fmt:String, v:Dynamic):Bool {
		switch (fmt) {
			case "type_auto": b.addTypePathAuto(v);
			case "type_dot": b.addTypePath(v, ".".code);
			case "field_auto": b.addFieldPathAuto(v);
			case "base_type": b.addBaseTypeName(v);
			case "hint": b.addHintString(v);
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
		for (c in classList) if (c.objName == null) {
			var q = c.superClass;
			while (q != null) {
				var o = q.objName;
				if (o != null) {
					c.objName = o;
					break;
				} else q = q.superClass;
			}
		}
		for (a in abstractList) {
			if (a.meta.has(":std") && a.impl != null) a.impl.isStd = true;
		}
	}
	override function getPreproc():Array<SfOptImpl> {
		var r = super.getPreproc();
		var pre = [
			#if sfgml_catch_error
			new SfGmlCatchError(),
			#end
			new SfGmlWith(),
			new SfOptIndexes(),
			new SfOptBinop(),
			new SfGmlObjectDecl(),
			new SfGmlEnumCtr(),
			new SfGmlScriptExecuteWrap(),
		]; pre.reverse(); for (o in pre) r.unshift(o);
		r.moveToFront(SfOptInstanceOf);
		r.insertAfter(SfOptFunc, new SfGmlLocalFunc());
		r.push(new SfGmlInstanceOf());
		return r;
	}
	override function getOptimizers():Array<SfOptImpl> {
		var r = super.getOptimizers();
		if (sfConfig.analyzer) r.replace(SfOptAutoVar, new SfGmlAutoVar());
		r.push(new SfGmlRest());
		r.push(new SfGmlNativeString());
		r.push(new SfGmlArrayDecl());
		r.push(new SfGmlType());
		r.push(new SfGmlTypeSwitch());
		r.push(new SfGmlBigSwitch());
		r.push(new SfGmlRepeat());
		r.push(new SfGmlArgs());
		r.push(new SfGmlArrayAccess());
		r.push(new SfGmlCFor());
		return r;
	}
	
	override public function printExpr(r:SfBuffer, expr:SfExpr, ?wrap:Bool):Void {
		inline function addExpr(e:SfExpr, w:Bool) printExpr(r, e, w);
		inline function addExprs(e:Array<SfExpr>) {
			for (i in 0 ... e.length) {
				if (i > 0) r.addComma();
				addExpr(e[i], true);
			}
		}
		inline function addBlock(e:SfExpr) {
			r.addBlockOpen();
			r.addLine(1);
			addExpr(e, false);
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
			case SfConst(c): printConst(r, c, expr);
			case SfLocal(v): {
				printf(r, "%s%s", sfConfig.localPrefix, v.name);
			};
			case SfIdent(_name): r.addString(_name);
			case SfDynamic(_code, []): r.addString(_code);
			case SfDynamic(_code, _args): {
				if (_args.length >= 10) error(expr, "Too many arguments");
				n = _code.length - 2;
				l = 0; i = 0; while (i < n) {
					if (StringTools.fastCodeAt(_code, i) == "{".code
					&& StringTools.fastCodeAt(_code, i + 2) == "}".code) {
						k = StringTools.fastCodeAt(_code, i + 1) - "0".code;
						if (k >= 0 && k < 10) {
							r.addSub(_code, l, i - l);
							addExpr(_args[k], null);
							i += 2;
							l = i + 1;
						}
					}
					i += 1;
				}
				r.addSub(_code, l, n + 2 - l);
			};
			case SfArrayAccess(a, i) | SfEnumAccess(a, _, i): printf(r, "%x[%x]", a, i);
			case SfEnumParameter(_expr, _, _index): printf(r, "%x[%d]", _expr, _index + 1);
			case SfBinop(o = OpAssign | OpAssignOp(_), _.def => SfInstField(q, f), v): {
				if (f.parentClass.objName != null) {
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
							} else if (at.indexMap.exists(s)) {
								printf(r, "%x[@", q);
								at.printAnonFieldTo(r, s, at.indexMap[s]);
								printf(r, "]");
								z = false;
							}
							if (!z) {
								printSetOp(r, o, expr);
								r.addExpr(v, true);
							}
						}
					};
					case TInst(_.get() => ct, _): {
						var ct = classMap.baseGet(ct);
						if (ct != null && ct.objName != null) {
							printf(r, "%x.%s", q, f);
							printSetOp(r, o, expr);
							r.addExpr(v, true);
							z = false;
						}
					};
					default:
				}
				if (z) {
					expr.error("[SfGenerator:printExpr] Can't do dynamic field write on " + SfExprTools.dump(expr) + " type " + q.getType());
				}
			};
			case SfBinop(o = OpAssign | OpAssignOp(_), _.def => SfArrayAccess(a, i), v): {
				switch (a.def) {
					case SfInstField(_, f) | SfStaticField(_, f)
					if (f.noRefWrite): printf(r, "%x[%x]", a, i);
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
			case SfBinop(o, a, b): { // a @ b
				addExpr(a, true);
				printBinOp(r, o, expr);
				addExpr(b, true);
			};
			case SfUnop(o = OpIncrement | OpDecrement, _postFix, x): { // ++\--
				z = (o == OpIncrement);
				if (!_postFix || wrap == false) r.addString(z ? "++" : "--");
				switch (x.def) {
					case SfInstField(q, f): {
						if ((i = f.index) >= 0) {
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
					default: r.addExpr(x, true);
				}
				if (wrap != false && _postFix) r.addString(z ? "++" : "--");
			};
			case SfUnop(_op, _postFix, _expr): {
				if (wrap) {
					if (_postFix) addExpr(_expr, true);
					switch (_op) {
						case OpIncrement: r.addChar2("+".code, "+".code);
						case OpDecrement: r.addChar2("-".code, "-".code);
						case OpNot: r.addChar("!".code);
						case OpNeg: r.addChar("-".code);
						case OpNegBits: r.addChar("~".code);
					};
					if (!_postFix) addExpr(_expr, true);
				} else {
					expr.error("Can't apply " + _op.getName() + " here.");
				}
			};
			case SfInstField(_inst, _field): {
				if (_field.parentClass.objName != null) {
					printf(r, "%x.%s", _inst, _field.name);
				} else {
					i = _field.index;
					if (i >= 0) {
						printf(r, "%x[%d%(hint)]", _inst, i, _field.name);
					} else expr.error("Field " + _field.name + " has no index.");
				}
			};
			case SfStaticField(c, f): {
				if (f.isVar && !c.isStd) {
					r.addString("g_");
					r.addFieldPathAuto(f);
				} else {
					#if (!sfgml_version || sfgml_version < "2.1.5")
					if (!f.isVar && !(c.isHidden || c.isExtern)) {
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
					r.addString("g_");
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
							if (ct != null && ct.objName != null) {
								printf(r, "%x.%s", obj, _field);
								z = false;
							}
						};
						default:
					}
				}
				if (z) {
					expr.error("[SfGenerator:printExpr] Can't do dynamic field read for `" + _field + "` from `" + obj.dump() + "` (" + obj.getName() + "," + obj.getTypeNz() + ")");
				}
			};
			case SfTypeExpr(t): {
				if (Std.is(t, SfEnum)) {
					var e:SfEnum = cast t;
					if (e.isFake) expr.error("Can't reference a fake enum.");
				} else if (t.isExtern) {
					expr.error("Can't reference an extern class.");
				}
				r.addString("mt_");
				r.addTypePath(t, "_".code);
			}
			case SfParenthesis(x): printf(r, "(%x)", x);
			case SfArrayDecl(vals): {
				r.addChar("[".code);
				for (i in 0 ... vals.length) {
					if (i > 0) r.addComma();
					r.addExpr(vals[i], true);
				}
				r.addChar("]".code);
			};
			case SfCall(x, _args): { // func(...args)
				n = _args.length;
				sep = false;
				i = 2; // 1: expr, 2: par, -1: nothing
				
				// if we are calling a field that's being wget, we need to resolve that
				// this is asking for a refactor of some sort
				var selfExpr:SfExpr = null;
				switch (x.def) {
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
				switch (x.def) {
					case SfIdent(name): r.addString(name);
					case SfDynamic(code, []): {
						if (code.charCodeAt(code.length - 1) == "]".code) {
							i = 3;
						} else r.addString(code);
					};
					case SfConst(TSuper): {
						if (currentClass == null) {
							expr.error("Trying to call super outside a class");
						}
						var superClass = this.currentClass.superClass;
						printf(r, "%(field_auto)(this", superClass.constructor);
						i = 0; sep = true;
					};
					case SfInstField(_.def => SfConst(TSuper), _field): {
						r.addFieldPathAuto(_field);
						printf(r, "(this");
						sep = true;
						i = 0;
					};
					case SfStaticField(cl, fd): {
						if (fd.name == "set_2D" && fd.parentType.realPath == "gml.NativeArray"
							&& _args[0].def.match(SfLocal(_) | SfStaticField(_, _))
						) {
							printf(r, "%x[@%x,`%x]`=`%x", _args[0], _args[1], _args[2], _args[3]);
							return;
						} else if (!fd.isVar || fd.meta.has(":script")) {
							r.addFieldPathAuto(fd);
						} else i = 3;
					};
					case SfDynamicField(_inst, _field): {
						if (!_inst.isSimple()) {
							_inst.warning("This call may have side effects.");
						}
						printf(r, "script_execute(%x,`%x", x, _inst);
						sep = true;
						i = 0;
					};
					case SfInstField(_inst, _field): {
						k = _field.index;
						if (k >= 0) {
							if (_field.callNeedsThis) {
								if (!_inst.isSimple()) {
									_inst.warning("This call may have side effects.");
								}
								printf(r, "script_execute(%x,`%x", x, _inst);
							} else printf(r, "script_execute(%x", x);
							sep = true;
							i = 0;
						} else {
							k = 0;
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
							if (k <= 0) {
								//
							} else if (_inst.def.match(SfLocal(_) | SfStaticField(_, _))) {
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
							i = 0;
						}
					};
					case SfEnumField(_enum, _field): {
						if (_enum.nativeGen && sfConfig.hasArrayDecl) {
							printf(r, "[%d", _field.index);
							if (sfConfig.hint) {
								r.addHintOpen();
								printf(r, "%s.%s", _enum.name, _field.name);
								r.addHintClose();
							}
							i = 0; while (i < n) printf(r, ",`%x", _args[i++]);
							printf(r, "]");
							return;
						}
						r.addFieldPathAuto(_field);
						i = 2;
					};
					default: i = 3;
				}
				if (i & 3 == 3) {
					#if (sfgml_script_execute_wrap)
					var cf = SfGmlScriptExecuteWrap.map[n];
					if (cf != null) {
						printf(r, "%(field_auto)(", cf);
					} else 
					#end
					printf(r, "script_execute(");
					printf(r, "%x", x);
					if (selfExpr != null) {
						if (!selfExpr.isSimple()) {
							selfExpr.warning("This call may have side effects.");
						}
						printf(r, ", %x", selfExpr);
					}
					sep = true;
				} else if (i & 2 != 0) r.addParOpen();
				//
				if (i >= 0) {
					i = 0; while (i < n) {
						if (sep) r.addComma(); else sep = true;
						addExpr(_args[i], true);
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
					addExpr(w[i], true);
					i += 1;
				}
				r.addParClose();
			};
			case SfNew(t, _, m): {
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
				r.addParOpen();
				addExprs(m);
				r.addParClose();
			};
			case SfVarDecl(v, z, x): { // var v = x
				printf(r, "var %s%s", sfConfig.localPrefix, v.name);
				printVarType(v);
				if (z) printf(r, "`=`%x", x);
			};
			case SfBlock(_exprs): { // { ...exprs }
				if (wrap == true) {
					error(expr, "Inline block: " + expr.dump());
				} else if (wrap == null) {
					if (_exprs.length != 1) {
						r.addBlockOpen();
						if (_exprs.length > 0) {
							r.addLine(1);
							addExpr(expr, false);
							r.addLine( -1);
						} else r.addSep();
						r.addBlockClose();
					} else addExpr(_exprs[0], null);
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
								default: addExpr(x, false);
							}
							sep = r.length > l;
							if (sep) r.addSemico();
						}
					}
				}
			};
			case SfIf(c, a, z, b): { // if (c) a else b
				if (wrap) {
					if (sfConfig.ternary) {
						if (z) {
							printf(r, "(%x`?`%x`:`%x)", c.unpack(), a, b);
						} else error(expr, "Inline single-branch if..?");
					} else error(expr, "Can't print an inline if-block.");
				} else printIf(r, c, a, b, true);
			};
			case SfWhile(_cond, _expr, _normal): {
				if (_normal) {
					printf(r, "while`%x`", _cond);
				} else r.addString("do ");
				r.addBlockExpr(_expr);
				if (!_normal) printf(r, " until`(%x)", _cond.invert());
			};
			case SfCFor(q, c, p, x): {
				printf(r, "for`(");
				switch (q.def) {
					case SfBlock([]): r.addString(";");
					default: printf(r, "%(block);", q);
				}
				printf(r, "`%x;`%(block))`", c.unpack(), p);
				addBlock(x);
			};
			case SfSwitch(_expr, _cases, _, _default): {
				printSwitch(r, _expr, _cases, _default);
			};
			case SfReturn(z, x): { // return x
				r.addString("return ");
				#if (sfgml_tracecall)
				printf(r, 'tracecall("- %z",`', r.addFieldPathAuto(currentField));
				#end
				if (z) {
					r.addExpr(x, true);
				} else r.addString("0");
				#if (sfgml_tracecall)
				printf(r, ")");
				#end
			}
			case SfBreak: r.addString("break");
			case SfContinue: r.addString("continue");
			case SfThrow(x): {
				switch (x.def) {
					case SfNew(c, _, [v]) if (c.name == "HaxeError"): x = v;
					default:
				}
				printf(r, "show_error(%x,`false)", x);
			};
			case SfCast(x, _): addExpr(x, wrap);
			case SfMeta(m, x): addExpr(x, wrap);
			default: error(expr, "Can't print " + expr.getName());
		} // switch (expr)
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
				r.addExpr(b, true);
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
		if (small) r.addExpr(t, null); else r.addBlockExpr(t);
		if (x != null) {
			printf(r, "; else ");
			switch (x.def) {
				case SfIf(c, t, z, x): printIf(r, c, t, x, false);
				default: r.addExpr(x, null);
			}
		}
	}
	
	private inline function printSwitch(r:SfBuffer, expr:SfExpr, cw:Array<SfExprCase>, cd:SfExpr) {
		var z:Bool;
		// enum data (if sf-hint is set):
		var expru = expr.unpack();
		var em = null, ng = false, e:SfEnum;
		switch (expru.def) {
			case SfEnumAccess(_, et, _.def => SfConst(TInt(0))): e = et;
			default: switch (expru.getType()) {
				case TEnum(_.get() => et, _): e = sfGenerator.enumMap.baseGet(et);
				default: e = null;
			}
		};
		if (e != null) {
			em = e.indexMap;
			ng = e.nativeGen && !sfConfig.gmxMode;
		}
		//
		var hint = sfConfig.hint;
		printf(r, "switch`(%x", expru);
		if (e != null && !ng && hint) {
			r.addHintOpen();
			r.addTypePathAuto(e);
			r.addHintClose();
		}
		printf(r, ")`{");
		r.addLine(1);
		//
		var trail = false;
		for (cc in cw) {
			if (trail) r.addLine(); else trail = true;
			// "case v1: case v2:"
			var cv = cc.values;
			for (k in 0 ... cv.length) {
				if (k > 0) r.addSep();
				r.addString("case ");
				var v = cv[k];
				if (ng) switch (v.def) {
					case SfConst(TInt(i)) if (em[i] != null): {
						printf(r, "%(type_auto).%s", e, em[i].name);
					};
					default: r.addExpr(v, true);
				} else {
					r.addExpr(v, true);
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
				r.addExpr(x, false);
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
				r.addExpr(cd, false);
				r.addSemico();
				if (z) r.indent -= 1;
			}
		}
		r.addLine(-1);
		r.addBlockClose();
	}
	
}
