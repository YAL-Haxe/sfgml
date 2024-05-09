package sf.opt.syntax;
import sf.type.expr.SfExpr;
import sf.type.expr.SfExprDef.*;
import sf.type.expr.SfExprList;
using sf.type.expr.SfExprTools;

/**
 * Having blocks/calls as for-loop initializer is not allowed anymore
 * so we'll move it out if needed.
 * @author YellowAfterlife
 */
class SfGmlCFor extends SfOptImpl {
	override public function apply() {
		forEachExpr(function(e:SfExpr, st:SfExprList, fn:SfExprIter) {
			e.iter(st, fn);
			switch (e.def) {
				case SfCFor(q, c, p, x): {
					switch (q.def) {
						case SfBlock([
							_.def => SfVarDecl(v1, z1, x1),
							_.def => SfVarDecl(v2, z2, x2),
						]): return;
						case SfBlock(_), SfCall(_, _): {};
						default: return;
					};
					e.def = SfBlock([
						q,
						e.mod(SfCFor(e.mod(SfBlock([])), c, p, x))
					]);
				};
				default:
			};
		}, []);
	}
}
