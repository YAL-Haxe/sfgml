package sf.opt.api;

import sf.type.expr.SfExpr;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;
import haxe.macro.Type;

/**
 * GML doesn't have a String constructor (only a converter)
 * and we don't want a reference to String type just because you
 * referenced String somewhere.
 * @author YellowAfterlife
 */
class SfGml_String_new extends SfOptImpl {
	override public function apply():Void {
		var s = sfGenerator.typeString;
		if (s == null || s.constructor == null) return;
		forEachExpr(function(e:SfExpr, st, fn) {
			e.iter(st, fn);
			switch (e.def) {
				case SfNew(c, _, args) if (c == s): {
					e.def = SfCall(e.mod(SfIdent("string")), args);
				};
				default:
			}
		});
		s.constructor = null;
	}
}