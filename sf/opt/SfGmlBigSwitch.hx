package sf.opt;

import haxe.macro.Type;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.expr.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlBigSwitch extends SfOptImpl {
	private function applyIter(e:SfExpr, w:SfExprList, f:SfExprIter) {
		var val:SfExpr;
		var ccs:Array<SfExprCase>;
		var def:SfExpr;
		switch (e.def) {
			case SfSwitch(v, c, z, d): {
				val = v;
				ccs = c;
				def = d;
			};
			default: return;
		}
		if (ccs.length < 16) return;
		switch (val.getType()) {
			case Type.TAbstract(_.get() => { name: "Int" }, _): { };
			default: return;
		}
		//
		var out:Array<{ val:Int, ccs:Array<SfExprCase> }> = [];
		var min:Int = 0, max:Int = 0;
		var shr:Int = 4;
		//
		for (cc in ccs) {
			var cchi:Int = 0;
			var ccfirst = true;
			for (ccv in cc.values) {
				var id:Int = switch (ccv.def) {
					case SfConst(TInt(i)): i;
					default: return;
				}
				var ccx = cc.expr;
			}
		}
	}
	override public function apply() {
		//forEachExpr(applyIter);
	}
}
