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
	function proc(expr:SfExpr, stack:Array<SfExpr>, _:SfExprIter) {
		if (currentClass == null) return;
		var locals:Map<String, Bool> = null;
		var lfIndex:Int = 0;
		var prev = null;
		function seek(e:SfExpr, w:Array<SfExpr>, f:SfExprIter) {
			switch (e.def) {
				case SfFunction(f): {
					// index main function locals if we might,
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
							#if !(haxe <= "4.0.0-preview.4")
							isFinal: true,
							isExtern: false,
							#end
						};
						//
						var sfd = new SfClassField(currentClass, cf, false);
						sfd.isAutogen = true;
						for (i in 0 ... f.args.length) {
							sfd.args[i] = f.args[i];
						}
						sfd.expr = f.expr;
						// poke in the field map item before we recurse so that
						// field names do not overlap but inner functions are defined
						// before the outer functions
						currentClass.fieldMap.set(name, sfd);
						proc(sfd.expr, [], proc);
						currentClass.addFieldBefore(sfd, currentField);
						//
						var sfv = f.sfvar;
						if (sfv != null) {
							expr.replaceLocal(sfv, sfd.toExpr());
							e.def = SfBlock([]);
							/*switch (w[0].def) {
								case SfBlock(m): {
									if (!m.remove(e)) e.def = SfBlock([]);
								};
								default: e.def = SfBlock([]);
							}*/
						} else e.def = sfd.toExpr().def;
					}
				};
				default: prev = e; e.iter(w, f);
			}
		};
		seek(expr, stack, seek);
	}
	override public function apply() {
		super.apply();
		forEachExpr(proc, []);
	}
}
