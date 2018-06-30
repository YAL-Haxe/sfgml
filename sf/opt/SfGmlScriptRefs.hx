package sf.opt;

import haxe.ds.Map;
import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;
import haxe.macro.Expr.Unop;

/**
 * https://bugs.yoyogames.com/view.php?id=29203
 * @author YellowAfterlife
 */
class SfGmlScriptRefs extends SfOptImpl {
	public static var init:String = "";
	override public function apply() {
		var buf = new SfBuffer();
		var map = new Map();
		forEachExpr(function(e:SfExpr, w:SfExprList, f:SfExprIter) {
			do switch (e.def) {
				case SfStaticField(c, f): {
					if (c.isExtern || c.isHidden) continue;
					if (f.isVar || f.isHidden) continue;
					if (w.length > 0) switch (w[0].def) {
						case SfCall(x, _) if (x == e): continue;
						default:
					};
					if (map.exists(f)) continue;
					map.set(f, true);
					printf(buf, 'globalvar f_');
					buf.addFieldPathAuto(f);
					printf(buf, ';`f_');
					buf.addFieldPathAuto(f);
					printf(buf, '`=`asset_get_index("', f);
					buf.addFieldPathAuto(f);
					printf(buf, '");\n', f);
				};
				default:
			} while (false);
			e.iter(w, f);
		}, []);
		init = buf.toString();
	}
}
