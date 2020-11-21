package sf.opt;
import sf.type.expr.SfExpr;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.opt.syntax.*;
import sf.opt.legacy.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlAutoVar extends SfOptAutoVar {
	override public function canInsertInto(expr:SfExpr):Bool {
		return switch (expr.def) {
			case SfDynamic(s, _) if (s == SfGmlWith.withCode): false;
			default: super.canInsertInto(expr);
		}
	}
	override public function hasSideEffects(expr:SfExpr, stack:Array<SfExpr>, repl:SfExpr):Bool {
		var first:SfExpr = stack.unpackStack();
		if (first != null) switch (first.def) {
			case SfArrayAccess(x, _): {
				if (x == expr && SfGmlArrayAccess.needsWrapping(repl)) return true;
			};
			case SfInstField(_, f): {
				if (f.index >= 0 && SfGmlArrayAccess.needsWrapping(repl)) return true;
				if (SfCore.sfConfig.avoidArrayAccessCalls) {
					// #177723: a().b() uses incorrect `self` in JS
					var next = stack[stack.indexOf(first) + 1];
					if (next != null) switch (next.def) {
						case SfCall(x, _) if (x == first
							&& repl.unpack().def.match(SfCall(_, _))
						): return true;
						default:
					}
				}
			};
			// #177710: a[b](...) compiles to invalid JS in 2.3.1
			case SfCall(x, _) if (x == expr
				&& SfCore.sfConfig.avoidArrayAccessCalls
				&& repl.unpack().def.match(SfArrayAccess(_, _))
			): return true;
			default:
		}
		//expr.warning("" + expr + " || " + first + " || " + repl.unpack() + " || " + stack);
		return super.hasSideEffects(expr, stack, repl);
	}
	
}
