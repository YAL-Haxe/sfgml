package sf.opt.api;

import sf.SfCore.*;
import sf.opt.SfOptImpl;
import sf.type.SfClass;
import sf.type.SfClassField;
import sf.type.expr.SfExpr;
import sf.type.expr.SfExprDef.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGml_MetaType extends SfOptImpl {
	public static var usesClassConstructors:Bool = false;
	function applyConstructor() {
		#if sfgml_keep_metatype_constructor
		usesClassConstructors = true;
		#else
		usesClassConstructors = false;
		var cl = sfGenerator.findRealClass("gml.MetaClass");
		if (cl == null) return;
		var fd = cl.realMap["constructor"];
		if (fd == null) return;
		//
		var found = false;
		function rec(x:SfExpr, st, it) {
			switch (x.def) {
				case SfInstField(_, f) if (f == fd): {
					found = true;
					return true;
				};
				default: return x.matchIter(st, it);
			}
		}
		forEachExpr(function(x:SfExpr, _, _) {
			if (found) return;
			if (currentClass != null && currentClass.module == "gml.MetaType") return;
			rec(x, null, rec);
		});
		if (!found) fd.isHidden = true;
		usesClassConstructors = found;
		#end
	}
	override public function apply():Void {
		applyConstructor();
	}
}