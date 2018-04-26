package sf.opt;

import sf.type.SfExpr;
import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
import sf.SfCore.*;
using sf.type.SfExprTools;
import haxe.macro.Type;

/**
 * Unwraps simple string operations with predictable results.
 * @author YellowAfterlife
 */
class SfGmlNativeString extends SfOptImpl {
	override public function apply() {
		var ns = sfGenerator.realMap["gml.NativeString"];
		if (ns == null) return;
		forEachExpr(function(e:SfExpr, st, fn) {
			e.iter(st, fn);
			switch (e.def) { case SfCall(_.def => SfStaticField(c, f), w): if (c == ns) {
				switch (f.name) {
					case "delete": switch (w) {
						case [s, // `string_delete(s, 1, 0)` -> `s`
							_.def => SfConst(TInt(1)),
							_.def => SfConst(TInt(0))
						]: e.def = s.def;
						default:
					};
					case "copy": switch (w) {
						case [s, // `string_copy(s, 1, alot)` -> `s`
							_.def => SfConst(TInt(1)),
							_.def => SfConst(TInt(0x7fffffff))
						]: e.def = s.def;
						default:
					};
				}
			}; default: }
		});
	}
}
