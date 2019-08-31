package sf.opt;
import sf.opt.SfOptImpl;
import sf.type.*;
import sf.type.expr.*;
import sf.type.expr.SfExprDef.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlCatchError extends SfOptImpl {
	override public function apply():Void {
		var typeBoot = SfCore.sfGenerator.typeBoot;
		var catcherFunc = typeBoot != null ? typeBoot.realMap["catch_error"] : null;
		var ceUsed = false;
		forEachExpr(function(expr:SfExpr, st:SfExprList, it:SfExprIter) {
			expr.iter(st, it);
			switch (expr.def) {
				case SfTry(stat, cc): {
					if (cc.length != 1) {
						expr.error("Only single-catch is supported for now");
						return;
					}
					var c = cc[0];
					var cx = c.expr;
					//
					var errorTextFunc:SfExprDef;
					if (catcherFunc != null) {
						errorTextFunc = SfStaticField(typeBoot, catcherFunc);
					} else {
						errorTextFunc = SfDynamic("catch_error_dequeue", []);
					}
					var errorTextVal = cx.mod(SfCall(cx.mod(errorTextFunc), []));
					var then:Array<SfExpr> = [
						cx.mod(SfVarDecl(c.v, true, errorTextVal))
					];
					if (catcherFunc == null) {
						var clearFunc = cx.mod(SfDynamic("catch_error_clear", []));
						then.push(cx.mod(SfCall(clearFunc, [])));
					}
					then.push(cx);
					//
					var sizeFunc = cx.mod(SfDynamic("catch_error_size", []));
					var callSize = cx.mod(SfCall(sizeFunc, []));
					expr.def = SfBlock([
						stat,
						cx.mod(SfIf(
							cx.mod(SfParenthesis(callSize)),
							cx.mod(SfBlock(then)),
							false, null
						))
					]);
				};
				default: 
			}
		});
	}
}
