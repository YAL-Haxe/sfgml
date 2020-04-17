package sf.opt;

import haxe.ds.Map;
import sf.type.*;
import sf.type.expr.*;
import sf.type.expr.SfExpr;
import sf.SfCore.*;
import sf.type.expr.SfExprTools.SfExprIter;
import sf.type.expr.SfExprDef.*;
using sf.type.expr.SfExprTools;

/**
 * Assigns indexes to all types and fields.
 * TODO: Can probably do without assigning indexes to extern classes..?
 * @author YellowAfterlife
 */
class SfOptIndexes extends SfOptImpl {
	function getIndexes(c:SfClass, addNames:Bool):Int {
		// if this is an object-class, don't assign indexes at all:
		if (c.dotAccess) return -1;
		// otherwise, if indexes weren't assigned yet,
		if (c.indexes < 0) {
			var i:Int = 0;
			var superClass = c.superClass;
			if (superClass != null) {
				#if !sfgml_legacy_meta
				if (superClass.nativeGen && !c.nativeGen) {
					haxe.macro.Context.error(
						'You can\'t inherit from a @:nativeGen class (${superClass.realPath}) '+
						'into a non-@:nativeGen class (${c.realPath}).',
						c.classType.pos);
				}
				#end
				i = getIndexes(superClass, addNames);
				if (i >= 0) c.fieldsByIndex = superClass.fieldsByIndex.copy();
			} else {
				#if !sfgml_legacy_meta
				if (!c.nativeGen) i++;
				#end
			}
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
					c.fieldsByIndex[fd.index] = fd;
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
				c.fieldsByIndex[i] = fd;
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
		// auto-allocate indexes for select core types:
		inline function autoMark(t:SfType):Void {
			if (t != null) t.index = i++;
		}
		autoMark(sfGenerator.typeVoid);
		autoMark(sfGenerator.typeDynamic);
		autoMark(sfGenerator.typeFloat);
		autoMark(sfGenerator.typeInt);
		autoMark(sfGenerator.typeBool);
		autoMark(sfGenerator.typeString);
		autoMark(sfGenerator.typeArray);
		//
		for (t in sfGenerator.typeList) {
			if (t.index >= 0) continue;
			if (t.isHidden || t.nativeGen) continue;
			if (Std.is(t, SfEnum)) {
				if ((cast t:SfEnum).isFake) continue;
			} else if (Std.is(t, SfClass)) {
				var c:SfClass = cast t;
				if (c.constructor == null && c.instList.length == 0) continue;
			} else continue;
			//Sys.println(i + "\t" + t.name);
			t.index = i++;
		}
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
