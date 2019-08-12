package sf.opt;

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
 * "better safe than sorry", wrap bitwise operators in parenthesis,
 * since GML operator precedence is weird.
 * @author YellowAfterlife
 */
class SfOptBinop extends SfOptImpl {
	
	var cStd:SfClass;
	var toString:SfClassField;
	var toStringUsed = false;
	
	/**
	 * GML operator precedence doesn't accurately match that of Haxe,
	 * so it's better to add a couple of parentheses here and there.
	 */
	function wrapBitOperations(e:SfExpr, w:SfExprList, f:SfExprIter) {
		e.iter(w, f);
		switch (e.def) {
			case SfBinop(o, a, b): {
				var wrap = false;
				if (w.length > 0) switch (o) {
					case OpAnd, OpOr, OpXor, OpShl, OpShr, OpUShr: {
						switch (w[0].def) {
							case null: { };
							case SfParenthesis(_): { };
							default: wrap = true;
						}
					};
					case OpLt, OpLte, OpGt, OpGte, OpEq, OpNotEq: {
						switch (w[0].def) {
							case SfBinop(OpEq | OpNotEq, _, _): wrap = true;
							default: { };
						}
					};
					default: { };
				}
				if (wrap) {
					e.setTo(SfParenthesis(e.mod(SfBinop(o, a, b))));
				}
			}
			default:
		}
	}
	
	/**
	 * GML can't do <<= and >>= operators for some reason, therefore
	 * `a <<= 1` must be expanded to `a = a << 1`
	 */
	function expandAssignmentShifts(e:SfExpr, w:SfExprList, f:SfExprIter) {
		e.iter(w, f);
		switch (e.def) {
			case SfBinop(OpAssignOp(o = OpShl | OpShr | OpUShr), vx = (
				_.def => SfLocal(_)
				| SfInstField(_.def => SfLocal(_) | SfConst(TThis), _)
			), x): {
				e.setTo(SfBinop(OpAssign, vx, e.mod(SfBinop(o, vx.clone(), x))));
			};
			default:
		}
	}
	
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
		} else cx = x.mod(SfDynamic("string", []));
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
					x = e.mod(SfCall(e.mod(SfDynamic("string", [])), [b.unpack()]));
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
	
	/**
	 * Older versions of GMS had a thing where doing (array != null) could raise an error.
	 */
	function wrapNullChecks(e:SfExpr, w:SfExprList, f:SfExprIter) {
		e.iter(w, f);
		switch (e.def) {
			case SfBinop(o = OpEq | OpNotEq, v, _.def => SfConst(TNull))
			| SfBinop(o = OpEq | OpNotEq, _.def => SfConst(TNull), v): {
				// (v != null) -> !is_undefined(v)
				var x = e.mod(SfCall(e.mod(SfDynamic("is_undefined", [])), [v]));
				if (o == OpNotEq) x = e.mod(SfUnop(OpNot, false, x));
				e.def = x.def;
			};
			default:
		}
	}
	
	/**
	 * Convert (a - 1 >= 0) to (a >= 1), cause why would you not.
	 */
	function simplifyComparisonsWithConstants(e:SfExpr, w:SfExprList, f:SfExprIter) {
		e.iter(w, f);
		switch (e.def) {
			case SfBinop(
				o = OpEq | OpNotEq | OpLt | OpLte | OpGt | OpGte,
				a = _.def => SfBinop(
					o2 = OpAdd | OpSub,
					a1,
					_.def => SfConst(TInt(i))
				),
				b = _.def => SfConst(TInt(k))
			): {
				a.def = a1.def;
				b.def = SfConst(TInt(k + (o2 == OpAdd ? -i : i)));
			};
			default:
		}
	}
	
	function checkToString(e:SfExpr, w:SfExprList, f:SfExprMatchIter) {
		switch (e.def) {
			case SfStaticField({module:"Std"}, {name:"string"}): {
				return true;
			};
			default:
		}
		return e.matchIter(w, f);
	}
	
	override public function apply() {
		cStd = cast sfGenerator.realMap["Std"];
		toString = cStd != null ? cStd.staticMap["string"] : null;
		forEachExpr(wrapBitOperations, []);
		forEachExpr(expandAssignmentShifts);
		forEachExpr(modifyExplicitStringCasts);
		forEachExpr(insertExplicitStringCasts);
		#if (sfgml_version && sfgml_version <= "1.4.1763")
		forEachExpr(wrapNullChecks);
		#end
		forEachExpr(simplifyComparisonsWithConstants);
		if (toString != null && !toStringUsed && !matchEachExpr(checkToString)) {
			toString.isHidden = true;
		}
	}
}
