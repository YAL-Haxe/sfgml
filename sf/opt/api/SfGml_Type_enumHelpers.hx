package sf.opt.api;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.type.SfTypeMap;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**

@author YellowAfterlife
**/
class SfGml_Type_enumHelpers extends SfOptImpl {
	public static var code:String = null;
	override public function apply() {
		ignoreHidden = true;
		code = "";
		//
		var clType:SfClass = cast sfGenerator.realMap["Type"];
		if (clType == null) return;
		//
		var clArrayImpl = sfGenerator.findRealClass("gml.internal.ArrayImpl");
		function getArrayImplField(x:SfExpr, rn:String):SfClassField {
			if (clArrayImpl == null) {
				x.warning('ArrayImpl is needed for $rn but is amiss.');
				return null;
			} else {
				var fd = clArrayImpl.realMap[rn];
				if (fd == null) x.warning('ArrayImpl.$rn is needed but amiss.');
				return fd;
			}
		}
		//
		var found = new SfTypeMap<String>();
		var out = new SfBuffer();
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var fdArrayDecl = sfGenerator.typeBoot.realMap["decl"];
		function ensureNames(sfEnum:SfEnum):String {
			var namesPath = found.sfGet(sfEnum);
			if (namesPath == null) {
				// bit of a hack: this runs before SfGmlSnakeCase,
				// so we'll need to process the enum earlier on.
				SfGmlSnakeCase.procEnum(sfEnum);
				namesPath = {
					var b = new SfBuffer();
					printf(b, "g_%(type_auto)_constructors", sfEnum);
					b.toString();
				};
				found.sfSet(sfEnum, namesPath);
				printf(out, "globalvar %s;`", namesPath);
				printf(out, "%s`=`", namesPath);
				if (!hasArrayDecl) {
					out.addFieldPathAuto(fdArrayDecl);
					out.addChar("(".code);
				} else out.addChar("[".code);
				var sep = false;
				for (ctr in sfEnum.ctrList) {
					if (sep) printf(out, ",`"); else sep = true;
					printf(out, '"%s"', ctr.name);
				}
				out.addChar(hasArrayDecl ? "]".code : ")".code);
				printf(out, ";\n");
			}
			return namesPath;
		}
		function getNamesExpr(x:SfExpr, e:SfEnum):SfExpr {
			return x.mod(SfIdent(ensureNames(e)));
		}
		//
		function getTypeEnum(v:SfExpr):SfEnum {
			switch (v.unpack().def) {
				case SfTypeExpr(t) if (Std.is(t, SfEnum)): return cast t;
				default: return null;
			}
		}
		function getExprEnum(v:SfExpr):SfEnum {
			switch (v.getTypeNz()) {
				case TEnum(_.get() => et, _): return sfGenerator.enumMap.baseGet(et);
				default: {
					switch (v.def) {
						case SfCast(v0, _): return getExprEnum(v0);
						default: return null;
					}
				}
			}
		}
		inline function checkEnum(e:SfEnum):Bool {
			return e != null && (e.isFake || (e.nativeGen && !e.isStruct));
		}
		//
		var hideField_count = 0;
		var hideField_fd:SfClassField;
		inline function hideField(name:String):Void {
			hideField_fd = clType.realMap[name];
			if (hideField_fd != null) {
				hideField_fd.isHidden = true;
				hideField_count += 1;
			}
		}
		hideField("getEnumConstructs");
		hideField("createEnumIndex");
		hideField("createEnum");
		hideField("enumConstructor");
		hideField("enumIndex");
		if (hideField_count == 0) return;
		//
		var dynNames:Bool = false;
		//
		function checkOne(x:SfExpr, f:SfClassField, w:Array<SfExpr>):Void {
			var v:SfExpr = w[0];
			var e:SfEnum, ep:String;
			switch (f.realName) {
				// taking an Enum<T>:
				case "getEnumConstructs": {
					e = getTypeEnum(v);
					if (checkEnum(e)) {
						// getEnumConstructs(f/n) -> enum_names
						var fdCopy = clArrayImpl.realMap["copy"];
						if (fdCopy != null) {
							fdCopy.isHidden = false;
							x.setTo(SfCall(
								x.mod(SfStaticField(fdCopy.parentClass, fdCopy)), [
									x.mod(SfIdent(ensureNames(e)))
								]
							));
						} else x.error("Can't find Array.copy for getEnumConstructs");
					} else {
						f.isHidden = false;
						if (e != null) {
							e.ctrNames = true;
						} else dynNames = true;
					}
				};
				case "createEnumIndex": {
					e = getTypeEnum(v);
					if (e != null) {
						if (e.isFake) {
							if (w.length > 2) switch (w[2].def) {
								case SfConst(TNull): {}; // OK!
								default: w[2].warning("Trying to create a fake enum with arguments.");
							}
							x.def = w[1].def;
						} else if (e.nativeGen) {
							var fi2 = getArrayImplField(x, "concatFront");
							var fx2 = x.mod(SfStaticField(fi2.parentClass, fi2));
							x.def = SfCall(fx2, [w[2], w[1]]);
						} else {
							e.ctrNames = true;
							f.isHidden = false;
						}
					} else dynNames = true;
				};
				case "createEnum": {
					e = getTypeEnum(v);
					if (e != null) {
						if (e.isFake) {
							if (w.length > 2) switch (w[2].def) {
								case SfConst(TNull): {}; // OK!
								default: w[2].warning("Trying to create a fake enum with arguments.");
							}
							var fi = getArrayImplField(x, "indexOf");
							if (fi == null) return;
							var fx = x.mod(SfStaticField(fi.parentClass, fi));
							x.def = SfCall(fx, [getNamesExpr(x, e), w[1]]);
						} else if (e.nativeGen) {
							var fi1 = getArrayImplField(x, "indexOf");
							var fx1 = x.mod(SfStaticField(fi1.parentClass, fi1));
							fx1 = x.mod(SfCall(fx1, [getNamesExpr(x, e), w[1]]));
							var fi2 = getArrayImplField(x, "concatFront");
							var fx2 = x.mod(SfStaticField(fi2.parentClass, fi2));
							x.def = SfCall(fx2, [w[2], fx1]);
						} else {
							e.ctrNames = true;
							f.isHidden = false;
						}
					} else dynNames = true;
				};
				// taking an EnumValue:
				case "enumConstructor": {
					e = getExprEnum(v);
					if (e != null) {
						if (checkEnum(e)) {
							// enum
							if (!e.isFake) { // ...need to pull out the index first
								v = v.mod(SfEnumAccess(v, e, v.mod(SfConst(TInt(0)))));
							}
							x.setTo(SfArrayAccess(getNamesExpr(x, e), v));
						} else {
							e.ctrNames = true;
							f.isHidden = false;
						}
					} else {
						f.isHidden = false;
						dynNames = true;
					}
				};
				case "enumIndex": {
					e = getExprEnum(v);
					if (e != null) {
						if (e.isStruct) {
							// enumIndex(struct) -> struct.__enumIndex__
							x.setTo(SfDynamicField(v, "__enumIndex__"));
						} else if (!e.isFake) {
							// enumIndex(array) -> array[0]
							x.setTo(SfEnumAccess(v, e, v.mod(SfConst(TInt(0)))));
						} else {
							// enumIndex(fake) -> fake
							x.setTo(v.def);
						}
					} else f.isHidden = false;
				};
			}
		}
		forEachExpr(function(x:SfExpr, w:SfExprList, f:SfExprIter) {
			x.iter(w, f);
			switch (x.def) {
				case SfCall(_.def => SfStaticField(c, f), w) if (c == clType): {
					checkOne(x, f, w);
				};
				default:
			}
		});
		if (dynNames) for (e in sfGenerator.enumList) {
			if (e.isHidden || e.isFake || e.nativeGen) continue;
			e.ctrNames = true;
		}
		code = out.toString();
	}
}
