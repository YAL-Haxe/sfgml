package sf.opt.api;

import sf.SfCore.*;
import sf.opt.SfOptImpl;
import sf.type.SfClass;
import sf.type.expr.SfExpr;
import sf.type.expr.SfExprDef.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlCullHelpers extends SfOptImpl {
	/**
	 * 
	 * @return Class if it was culled, null otherwise
	 */
	function cullClass(realPath:String):SfClass {
		var c = sfGenerator.findRealClass(realPath);
		if (c == null) return null;
		function matcher(x:SfExpr, st, it) {
			switch (x.def) {
				case SfStaticField(c1, _) if (c1 == c): return true;
				case SfTypeExpr(t) if (t == c): return true;
				case SfNew(c1, _, _) if (c1 == c): return true;
				default: return x.matchIter(st, it);
			}
		}
		var used = false;
		forEachExpr(function(x:SfExpr, st, it) {
			if (currentClass != null && currentClass == c) return;
			if (!used && matcher(x, null, matcher)) used = true;
		});
		if (used) return null;
		c.isHidden = true;
		return c;
	}
	override public function apply():Void {
		ignoreHidden = true;
		cullClass("gml.internal.NativeFunctionInvoke");
		cullClass("gml.internal.NativeConstructorInvoke");
		cullClass("IntIterator");
		cullClass("haxe.iterators.ArrayIterator");
		//
		var _Exception = cullClass("haxe.Exception");
		if (_Exception != null) {
			_Exception.hasTypeExpr = false;
			var vx = sfGenerator.findRealClass("haxe.ValueException");
			if (vx != null) vx.isHidden = true;
		}
	}
}