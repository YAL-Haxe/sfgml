package sf.opt.api;

import sf.SfCore.*;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExpr;
import sf.type.expr.SfExprDef.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlCullHelpers extends SfOptImpl {
	function checkClass(realPath:String):Void {
		var c = sfGenerator.findRealClass(realPath);
		if (c == null) return;
		function matcher(x:SfExpr, st, it) {
			switch (x.def) {
				case SfStaticField(c1, _) if (c1 == c): return true;
				case SfTypeExpr(t) if (t == c): return true;
				default: return x.matchIter(st, it);
			}
		}
		var used = false;
		forEachExpr(function(x:SfExpr, st, it) {
			if (currentClass != null && currentClass == c) return;
			if (!used && matcher(x, null, matcher)) used = true;
		});
		if (!used) {
			c.isHidden = true;
		}
	}
	override public function apply():Void {
		ignoreHidden = true;
		checkClass("gml.internal.NativeFunctionInvoke");
		checkClass("gml.internal.NativeConstructorInvoke");
	}
}