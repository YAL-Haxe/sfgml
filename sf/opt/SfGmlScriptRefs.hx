package sf.opt;

import haxe.ds.Map;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;
import haxe.macro.Expr.Unop;

/**
 * https://bugs.yoyogames.com/view.php?id=29203
 * @author YellowAfterlife
 */
class SfGmlScriptRefs extends SfOptImpl {
	public static var enabled:Bool = true;
	public static var init:String = "";
	override public function apply() {
		enabled = sfConfig.gmxMode;
		if (!enabled) return;
		var buf = new SfBuffer();
		var map = new Map();
		inline function proc(f:SfClassField):Void {
			if (map.exists(f)) return;
			map.set(f, true);
			printf(buf, 'globalvar f_');
			buf.addFieldPathAuto(f);
			printf(buf, ';`f_');
			buf.addFieldPathAuto(f);
			printf(buf, '`=`asset_get_index("', f);
			buf.addFieldPathAuto(f);
			printf(buf, '");\n', f);
		}
		
		// generate f_ for function references:
		forEachExpr(function(e:SfExpr, w:SfExprList, f:SfExprIter) {
			do switch (e.def) {
				case SfStaticField(c, f): {
					if (c.isExtern || c.isHidden) continue;
					if (f.isVar || f.isHidden) continue;
					if (w.length > 0) switch (w[0].def) {
						case SfCall(x, _) if (x == e): continue;
						default:
					};
					proc(f);
				};
				default:
			} while (false);
			e.iter(w, f);
		}, []);
		
		// and dynamic functions that'll be used in constructors:
		for (sfc in sfGenerator.classList) {
			if (sfc.isExtern || sfc.isHidden) continue;
			for (sfd in sfc.instList) {
				if (sfd.isHidden) continue;
				if (sfd.isDynFunc) proc(sfd);
			}
		}
		
		init = buf.toString();
	}
	public static function main(buf:SfBuffer):Void {
		new SfGmlScriptRefs().apply();
		if (init != "") {
			if (sfConfig.hintFolds) printf(buf, "//{ functions\n");
			buf.addString(init);
			if (sfConfig.hintFolds) printf(buf, "//}\n");
		}
	}
}
