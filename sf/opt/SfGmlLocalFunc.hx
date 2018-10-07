package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;

/**
 * GML is yet to support closures (planned tho), so local functions without scope access are best
 * exported into static class fields.
 * @author YellowAfterlife
 */
class SfGmlLocalFunc extends SfOptImpl {
	function getLocalsMap(expr:SfExpr):Map<String, Bool> {
		var out:Map<String, Bool> = new Map();
		function seek(e:SfExpr, w, f:SfExprIter) {
			switch (e.def) {
				case SfVarDecl(v, z, x): {
					out.set(v.name, true);
					if (z) f(x, w, f);
				};
				case SfFunction(_): { };
				default: e.iter(w, f);
			}
		}; seek(expr, null, seek);
		return out;
	}
	function usesLocals(expr:SfExpr, locals:Map<String, Bool>):Bool {
		function check(e:SfExpr, w, f:SfExprMatchIter) {
			return switch (e.def) {
				case SfLocal(v): locals.get(v.name);
				case SfConst(TThis): true;
				default: e.matchIter(w, f);
			}
		}; return check(expr, null, check);
	}
	override public function apply() {
		super.apply();
		forEachExpr(function(expr:SfExpr, stack:Array<SfExpr>, _:SfExprIter) {
			if (currentClass == null) return;
			var locals:Map<String, Bool> = null;
			var lfIndex:Int = 0;
			var prev = null;
			function seek(e:SfExpr, w:Array<SfExpr>, f:SfExprIter) {
				switch (e.def) {
					case SfFunction(f): {
						if (locals == null) locals = getLocalsMap(expr);
						if (!usesLocals(f.expr, locals)) {
							// decide on the outlined function name:
							var namePrefix:String;
							if (currentField != null) {
								namePrefix = currentField.name + "_";
							} else namePrefix = "";
							if (f.name != null) {
								namePrefix += f.name;
							} else {
								if (w.length > 0) switch (w[0].def) {
									case SfBinop(OpAssign,
										_.def => SfInstField(_, fd),
									v) if (v == e): {
										namePrefix += fd.name;
									};
									default: namePrefix += "lf";
								} else namePrefix += "lf";
							}
							var name:String;
							if (!currentClass.fieldMap.exists(namePrefix)) {
								name = namePrefix;
							} else do {
								name = namePrefix + (++lfIndex);
							} while (currentClass.fieldMap.exists(name));
							//
							var cf:haxe.macro.Type.ClassField = {
								name: name,
								type: e.getType(),
								isPublic: false,
								params: [],
								meta: {
									get: function() return [],
									extract: function(_) return [],
									add: function(_, _, _) { },
									remove: function(_) { },
									has: function(_) return false,
								},
								kind: FMethod(MethNormal),
								expr: function() return null,
								pos: f.expr.getPos(),
								doc: null,
								overloads: null,
							};
							//
							var sf = new SfClassField(currentClass, cf, false);
							for (i in 0 ... f.args.length) {
								sf.args[i] = f.args[i];
							}
							sf.expr = f.expr;
							currentClass.addFieldBefore(sf, currentField);
							//
							var sfv = f.sfvar;
							if (sfv != null) {
								expr.replaceLocal(sfv, sf.toExpr());
								e.def = SfBlock([]);
								/*switch (w[0].def) {
									case SfBlock(m): {
										if (!m.remove(e)) e.def = SfBlock([]);
									};
									default: e.def = SfBlock([]);
								}*/
							} else e.def = sf.toExpr().def;
						}
					};
					default: prev = e; e.iter(w, f);
				}
			};
			seek(expr, stack, seek);
		}, []);
	}
}
