package sf.opt.type;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;

/**
 * Since type references are in fact non-constant values in GML,
 * switch-blocks on them have to be handled separately.
 * @author YellowAfterlife
 */
class SfGmlTypeSwitch extends SfOptImpl {
	
	override public function apply() {
		var mtClass = sfGenerator.classMap.get(SfGmlType.mtModule, "type");
		if (mtClass == null) return;
		// fix up switches on types:
		var mtIndex = mtClass.fieldMap["index"];
		forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			var ti:Int;
			switch (e.def) {
				case SfSwitch(x, m, _, sdef): switch (x.getType()) {
					case TAbstract(_.get() => { module: "Class" }, _): {
						for (c in m) for (v in c.values) switch (v.def) {
							case SfTypeExpr(t): {
								ti = t.index;
								if (ti < 0) v.error("This type has no index.");
								v.setTo(SfConst(TInt(ti)));
							};
							default: v.error("When switching on types, cases may only be direct type references.");
						}
						var xu = x.unpack();
						switch (xu.getType()) {
							case TAbstract(_.get() => { module: "StdTypes", name: "Int" }, _): {
								// No field access needed.
							};
							default: {
								xu.setTo(SfInstField(xu.clone(), mtIndex));
							};
						}
					};
					default:
				};
				default:
			}
		});
	}
	
}
