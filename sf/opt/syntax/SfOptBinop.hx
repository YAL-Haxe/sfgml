package sf.opt.syntax;

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
			//
			case SfBinop(OpAssign | OpAssignOp(_), _,
				_.def => SfBinop(OpAssign | OpAssignOp(_), _, _)
			): {
				SfExprTools.error(e, "Can't do chain assignment in GML");
			};
			//
			case SfBinop(OpAssign, vx,
				_.unpack() => _.def => SfBinop(o = OpAnd | OpOr | OpXor, ax, bx)
			) if (vx.equals(ax.unpack())): {
				e.setTo(SfBinop(OpAssignOp(o), vx, bx));
			}
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
	
	/**
	 * GML doesn't have operator overloading, meaning that it's OK to change
	 * if (!(a < b)) to if (a >= b)
	 */
	function simplifyIfNots(e:SfExpr, w:SfExprList, f:SfExprIter) {
		e.iter(w, f);
		var cond:SfExpr, notx:SfExpr;
		switch (e.def) {
			case SfIf(_cond, _, _, _):
				cond = _cond.unpack();
				notx = switch (cond.def) {
					case SfUnop(OpNot, false, _notx): _notx;
					default: return;
				}
			default: return;
		}
		var w = notx.invert(true);
		if (w != null) cond.def = w.def;
	}
	
	override public function apply() {
		ignoreHidden = true;
		//
		forEachExpr(wrapBitOperations, []);
		forEachExpr(expandAssignmentShifts);
		#if (sfgml_version && sfgml_version <= "1.4.1763")
		forEachExpr(wrapNullChecks);
		#end
		forEachExpr(simplifyComparisonsWithConstants);
		forEachExpr(simplifyIfNots);
	}
}
