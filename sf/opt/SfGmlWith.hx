package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * Converts `for (q in NativeScope.with(o)) { ... }` to a GML-specific with-loop.
 * Changes iterator to `self`/`other` keywords, where possible.
 * @author YellowAfterlife
 */
class SfGmlWith extends SfOptImpl {
	public static inline var withCode = "with ({0}) {1}";
	static function replaceWithIter(expr:SfExpr, local:SfVar, c:SfClass) {
		var depth = 0;
		var keep = false;
		var c_self = c.staticMap["self"];
		var c_other = c.staticMap["other"];
		function seek(e:SfExpr, w, func:SfExprIter):Void {
			switch (e.def) {
				case SfLocal(v): {
					if (v.equals(local)) switch (depth) {
						case 0: e.def = SfStaticField(c, c_self);
						case 1: e.def = SfStaticField(c, c_other);
						default: keep = true;
					}
				};
				case SfDynamic(s, _) if (s == withCode): {
					depth += 1;
					e.iter(w, func);
					depth -= 1;
				};
				default: e.iter(w, func);
			}
		}; seek(expr, null, seek);
		return keep;
	}
	static function unpackWithLoops(expr:SfExpr, w:Array<SfExpr>, f:SfExprIter) {
		expr.iter(w, f);
		switch (expr.def) {
			case SfBlock([
				_.def => SfVarDecl(v, true, vx),
				_.def => SfWhile(c, loop = _.def => SfBlock(exprs), true)
			]): {
				if (exprs.length < 1) return;
				// ensure `var v = gml.NativeScope.withIter(ctx)`:
				var sfc:SfClass;
				var filter:SfExpr = switch (vx.def) {
					case SfCall(_.def => SfStaticField(c = {
						realPath: "gml.NativeScope"
					}, {
						realName: "with"
					}), args): sfc = c; args[0]; // OK!
					default: return;
				}
				// ensure that loop condition is `v.hasNext()`:
				switch (c.unpack().def) {
					case SfCall(_.def => SfInstField(_.def => SfLocal(v1), 
						{ realName: "hasNext" }
					), []) if (v.equals(v1)): // OK!
					default: return;
				}
				// ensure that loop body starts with `var q = v.next();`:
				switch (exprs[0].def) {
					case SfVarDecl(v2, true, vx): {
						switch (vx.def) {
							case SfCall(_.def => SfInstField(_.def => SfLocal(v3), { realName: "next" }
							), []) if (v.equals(v3)): {
								if (replaceWithIter(loop, v2, sfc)) {
									vx.def = SfStaticField(sfc, sfc.staticMap["self"]);
								} else exprs.splice(0, 1);
							};
							default: return;
						}
					};
					default: return;
				}
				expr.def = SfDynamic(withCode, [filter, loop]);
			};
			default:
		}
	}
	
	override public function apply() {
		forEachExpr(unpackWithLoops);
	}
	
}
