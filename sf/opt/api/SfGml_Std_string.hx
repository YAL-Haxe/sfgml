package sf.opt.api;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExpr;
import sf.SfCore.*;
import sf.type.expr.SfExprList;
import sf.type.SfClass;
import sf.type.SfClassField;
import sf.type.expr.SfExprTools.SfExprIter;
import sf.type.expr.SfExprDef.*;
import haxe.macro.Expr.Binop.*;
import haxe.macro.Type.TConstant.*;
using sf.type.expr.SfExprTools;

/**
 * Handles Std.string 
 * @author YellowAfterlife
 */
class SfGml_Std_string extends SfOptImpl {
	var cStd:SfClass;
	var toString:SfClassField;
	var toStringUsed = false;
	
	function wrapToString(x:SfExpr):SfExpr {
		var needStd = true;
		switch (x.getType().resolve()) {
			case TInst(_.get() => c, _): {
				if (c.module == "String") return x.clone();
			}
			case TAbstract(_.get() => a, _): {
				if (a.module == "StdTypes") switch (a.name) {
					case "Int", "Bool": needStd = false;
				} else switch (a.module) {
					case "haxe.Int64": needStd = false;
				}
			};
			default:
		}
		//
		var cx:SfExpr;
		if (needStd && toString != null) {
			toStringUsed = true;
			cx = x.mod(SfStaticField(cStd, toString));
		} else cx = x.mod(SfIdent("string"));
		return x.mod(SfCall(cx, [x.clone()]));
	}
	
	/**
	 * Haxe-JS generates `(v == null ? "null" : "" + v)`, while GML has a separate function.
	 */
	function modifyExplicitStringCasts(e:SfExpr, w:SfExprList, f:SfExprIter) {
		switch (e.def) {
			case SfIf(
				_.def => SfParenthesis(_.def => SfBinop(OpEq, val, _.def => SfConst(TNull))),
				_.def => SfConst(TString("null")), true,
				_.def => SfBinop(OpAdd, _.def => SfConst(TString("")), val1)
			) if (val.equals(val1)): {
				e.setTo(wrapToString(val).def);
			};
			default:
		}
		e.iter(w, f);
	}
	
	function insertExplicitStringCasts(e:SfExpr, w:SfExprList, f:SfExprIter) {
		e.iter(w, f);
		var x:SfExpr;
		switch (e.def) {
			case SfBinop(o = OpAssignOp(OpAdd), a, b): { // `s += i` -> `s += string(i)`
				if (a.isString() && !b.isString()) {
					x = e.mod(SfCall(e.mod(SfIdent("string")), [b.unpack()]));
					e.setTo(SfBinop(o, a, x));
				}
			};
			case SfBinop(OpAdd, a, b): { // `s + i` -> `s + string(i)`
				switch ([a.isString(), b.isString()]) {
					case [true, false]: {
						e.setTo(SfBinop(OpAdd, a, wrapToString(b.unpack())));
					};
					case [false, true]: {
						e.setTo(SfBinop(OpAdd, wrapToString(a.unpack()), b));
					};
					default:
				}
			};
			default:
		}
	}
	
	function checkToString(e:SfExpr, w:SfExprList, f:SfExprMatchIter) {
		if (currentField != null && currentField == toString) return false;
		switch (e.def) {
			case SfStaticField(_, f) if (f == toString): return true;
			default:
		}
		return e.matchIter(w, f);
	}
	
	var pass = 0;
	override public function apply():Void {
		ignoreHidden = true;
		if (pass++ == 0) {
			cStd = cast sfGenerator.realMap["Std"];
			toString = cStd != null ? cStd.staticMap["string"] : null;
			//
			forEachExpr(modifyExplicitStringCasts);
			forEachExpr(insertExplicitStringCasts);
		} else {
			if (toString != null && !toStringUsed) do {
				for (e in sfGenerator.enumList) {
					if (e.needsToString()) {
						toStringUsed = true;
						break;
					}
				}
				if (toStringUsed) break;
				if (matchEachExpr(checkToString)) break;
				toString.isHidden = true;
			} while (false);
		}
	}
}