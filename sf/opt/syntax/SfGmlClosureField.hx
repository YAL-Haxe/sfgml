package sf.opt.syntax;
import sf.type.expr.SfExpr;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;

/**
 * Convert `inst.func` to either `method(inst, inst.func)` or
 * `closurePost(closurePre(inst).func)` so that we bind it correctly.
 * @author YellowAfterlife
 */
class SfGmlClosureField extends SfOptImpl {
	override public function apply():Void {
		var jsBoot = sfGenerator.typeBoot;
		if (jsBoot == null) return;
		var jsBoot_closureSelf = jsBoot.realMap["closureSelf"];
		var jsBoot_closurePre = jsBoot.realMap["closurePre"];
		var jsBoot_closurePost = jsBoot.realMap["closurePost"];
		var usesWrap = false;
		//
		ignoreHidden = true;
		if (sfConfig.modern) forEachExpr(function(x:SfExpr, st:SfExprList, it:SfExprIter) {
			x.iter(st, it);
			switch (x.def) {
				case SfClosureField(inst, field): {
					if (inst.isSimple()) {
						x.def = SfCall(x.mod(SfIdent("method")), [
							inst,
							x.mod(SfInstField(inst.clone(), field)),
						]);
					} else {
						usesWrap = true;
						var pre = x.mod(SfStaticField(jsBoot, jsBoot_closurePre));
						var nx = x.mod(SfCall(pre, [inst]));
						nx = x.mod(SfInstField(nx, field));
						var post = x.mod(SfStaticField(jsBoot, jsBoot_closurePost));
						x.def = SfCall(post, [nx]);
					}
				};
				default:
			}
		});
		//
		if (!usesWrap) {
			jsBoot.removeField(jsBoot_closureSelf);
			jsBoot.removeField(jsBoot_closurePre);
			jsBoot.removeField(jsBoot_closurePost);
		}
	}
}
