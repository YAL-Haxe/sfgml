package sf.opt;
import sf.type.expr.SfExpr;
import sf.type.expr.SfExprDef.*;
import sf.type.expr.SfExprList;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlCFor extends SfOptImpl {
	override public function apply() {
		forEachExpr(function(e:SfExpr, st:SfExprList, fn:SfExprIter) {
			e.iter(st, fn);
			switch (e.def) {
				case SfCFor(q, c, p, x): {
					switch (q.def) {
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
