package sf.opt;

import haxe.ds.Map;
import sf.type.SfClass;
import sf.type.SfExpr;
import sf.SfCore.*;
import sf.type.SfExprTools.SfExprIter;
import sf.type.SfExprDef.*;
using sf.type.SfExprTools;

/**
 * Assigns indexes to all types and fields.
 * TODO: Can probably do without assigning indexes to extern classes..?
 * @author YellowAfterlife
 */
class SfOptIndexes extends SfOptImpl {
	function getIndexes(c:SfClass, addNames:Bool):Int {
		// if this is an object-class, don't assign indexes at all:
		if (c.objName != null) return -1;
		// otherwise, if indexes weren't assigned yet,
		if (c.indexes < 0) {
			var i:Int = 0;
			var superClass = c.superClass;
			if (superClass != null) i = getIndexes(superClass, addNames);
			// if parent is an object, we're an object too, so quit:
			if (i < 0) return -1;
			// otherwise assign indexes to all variable/dynfunc fields:
			for (fd in c.instList) if (fd.isVar) {
				var fdName = fd.name;
				// don't [re-]index overrides:
				var cc = superClass;
				var superField = null;
				while (cc != null) {
					superField = cc.instMap[fdName];
					if (superField != null && superField.index >= 0) break;
					cc = cc.superClass;
				}
				if (cc != null) {
					fd.index = superField.index;
					continue;
				}
				// don't index properties:
				switch (fd.classField.kind) {
					case FVar(AccCall|AccNo|AccNever, AccNever|AccNo|AccCall): {
						if (!fd.meta.has(":isVar")) continue;
					}
					default:
				}
				//
				if (addNames) i += 1;
				fd.index = i;
				i += 1;
			}
			// and cache the index count for children:
			c.indexes = i;
		}
		return c.indexes;
	}
	override public function apply() {
		var addNames = sfConfig.fieldNames;
		var i:Int = 0;
		for (t in sfGenerator.typeList) t.index = i++;
		sf.type.SfType.indexes = i;
		for (c in sfGenerator.classList) getIndexes(c, addNames);
		for (q in sfGenerator.anonList) {
			var i:Int = 0;
			for (f in q.fields) {
				f.index = i;
				q.indexMap.set(f.name, i);
				i += 1;
			}
			q.indexes = i;
		}
	}
}
