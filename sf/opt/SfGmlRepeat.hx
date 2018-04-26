package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;
import haxe.macro.Expr.Unop;

/**
 * Transforms `for (i in A ... B) { ... }` to `repeat (B-A) { ... }`
 * if iterator is unused instead of the loop.
 * @author YellowAfterlife
 */
class SfGmlRepeat extends SfOptImpl {
	override public function apply() {
		forEachExpr(function(e:SfExpr, w:SfExprList, f:SfExprIter) {
			do {
				var init:SfExpr, cond:SfExpr, post:SfExpr, expr:SfExpr;
				switch (e.def) {
					case SfCFor(_init, _cond, _post, _expr): {
						init = _init; cond = _cond;
						post = _post; expr = _expr;
					};
					default: continue;
				}
				//
				var iter:SfVar, start:Int;
				switch (init.def) {
					case SfVarDecl(v, true, _.def => SfConst(TInt(i))): {
						iter = v; start = i;
					};
					default: continue;
				}
				//
				var end:Int;
				switch (cond.def) {
					case SfBinop(OpLt,
						_.def => SfLocal(v), _.def => SfConst(TInt(i))
					) if (v.equals(iter)): end = i;
					default: continue;
				}
				//
				switch (post.def) {
					case SfBinop(OpAssignOp(OpAdd),
						_.def => SfLocal(v), _.def => SfConst(TInt(1))
					) if (v.equals(iter)): { };
					case SfUnop(Unop.OpIncrement, _, _.def => SfLocal(v)) if (v.equals(iter)): { };
					default: continue;
				}
				//
				if (expr.countLocal(iter) != 0) continue;
				//
				e.setTo(SfDynamic("repeat (" + (end - start) + ") {0}", [expr]));
			} while (false);
			e.iter(w, f);
		});
	}
}
