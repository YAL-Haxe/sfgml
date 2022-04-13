package sf.opt.legacy;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;

/**
 * GMS<2.3 does not support inline functions,
 * so we'll export local functions without scope access into static class fields.
 * 
 * On >=2.3 we'll just check that you are not trying to share scope since GML
 * doesn't support that and it'd need a fancy workaround like that on C#/Java.
 * @author YellowAfterlife
 */
class SfGmlLocalFunc extends SfOptImpl {
	static function getLocalsMap(expr:SfExpr):Map<String, SfVar> {
		var out:Map<String, SfVar> = new Map();
		function seek(e:SfExpr, w, f:SfExprIter) {
			switch (e.def) {
				case SfVarDecl(v, z, x): {
					out.set(v.name, v);
					if (z) f(x, w, f);
				};
				case SfFunction(_): { };
				default: e.iter(w, f);
			}
		}; seek(expr, null, seek);
		return out;
	}
	
	static function usesLocals(expr:SfExpr, locals:Map<String, SfVar>):SfExpr {
		var trouble:SfExpr = null;
		function check(e:SfExpr, w, f:SfExprMatchIter) {
			switch (e.def) {
				case SfLocal(v): {
					var v1 = locals[v.name];
					if (v1 != null && v1.equals(v)) {
						trouble = e;
						return true;
					} else return false;
				}
				case SfConst(TThis): {
					trouble = e;
					return true;
				};
				default: return e.matchIter(w, f);
			}
		};
		check(expr, null, check);
		return trouble;
	}
	
	function proc(expr:SfExpr, stack:Array<SfExpr>, _:SfExprIter) {
		if (currentClass == null) return;
		var locals:Map<String, SfVar> = null;
		var lfIndex:Int = 0;
		var prev = null;
		function seek(e:SfExpr, w:Array<SfExpr>, f:SfExprIter) {
			switch (e.def) {
				case SfFunction(f): {
					// index outer function's locals if we didn't yet,
					if (locals == null) locals = getLocalsMap(expr);
					//
					var nl = usesLocals(f.expr, locals);
					if (nl != null) {
						if (!sfConfig.modern) {
							e.warning("This function could not be inlined since it's using local scope from the container function,");
							nl.warning(", problematic expression here (" + nl.def + ")");
						}
						return;
					}
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
						#if (haxe >= "4.0.0")
						isFinal: true,
						isExtern: false,
						#end
						#if (haxe >= "4.2")
						isAbstract: false,
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
				};
				default: prev = e; e.iter(w, f);
			} // switch
		} // seek
		seek(expr, stack, seek);
	}
	function verifyFunc(func:SfExprFunction) {
		var locals = new Map();
		for (arg in func.args) locals[arg.v.name] = true;
		function verify(expr:SfExpr, st:SfExprList, it:SfExprIter) {
			switch (expr.def) {
				case SfLocal(v): {
					if (!locals.exists(v.name)) {
						expr.warning('Variable ${v.name} is not accessible here.');
					}
				};
				case SfVarDecl(v, set, expr): {
					locals[v.name] = true;
					if (set) expr.iter(st, it);
				};
				case SfFunction(fn): {
					if (fn.name != null) locals[fn.name] = true;
					verifyFunc(fn);
				};
				default: expr.iter(st, it);
			}
		}
		verify(func.expr, null, verify);
	}
	function verifyOuter(expr:SfExpr, st:SfExprList, it:SfExprIter) {
		switch (expr.def) {
			case SfFunction(fn): verifyFunc(fn);
			default: expr.iter(st, it);
		}
	}
	override public function apply() {
		var verifyOnly = sfConfig.hasFunctionLiterals;
		#if sfgml_keep_local_functions
		verifyOnly = false;
		#end
		if (verifyOnly) {
			forEachExpr(verifyOuter);
		} else {
			forEachExpr(proc, []);
		}
	}
}
