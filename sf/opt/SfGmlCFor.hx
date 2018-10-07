package sf.opt;
import sf.type.SfExpr;
import sf.type.SfExprDef.*;
import sf.type.SfExprList;
using sf.type.SfExprTools;

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
