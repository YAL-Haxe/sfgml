package sf.opt;
import sf.type.SfExpr;
import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;

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
		if (stack.length > 0) switch (stack[0].def) {
			case SfArrayAccess(x, _): {
				if (x == expr && SfGmlArrayAccess.needsWrapping(repl)) return true;
			};
			case SfInstField(_, f): {
				if (f.index >= 0 && SfGmlArrayAccess.needsWrapping(repl)) return true;
			};
			default:
		}
		return super.hasSideEffects(expr, stack, repl);
	}
	
}
