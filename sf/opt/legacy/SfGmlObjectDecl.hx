package sf.opt.legacy;

import haxe.macro.Type.DefType;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * GML does not have lightweight anonymous objects in pre-2.3,
 * so anonymous structures with known
 * fields are compiled into array-based structures.
 * Unwrapping is also handled here.
 * @author YellowAfterlife
 */
class SfGmlObjectDecl extends SfOptImpl {
	
	var bootClass:SfClass;
	var odeclField:SfClassField;
	var odeclUsed = false;
	var mdeclField:SfClassField;
	var mdeclUsed = false;
	var hasArrayDecl:Bool;
	var currentExprFunc:SfExprFunction = null;
	var hint:Bool;
	
	public function getTypeFromParent(orig:SfExpr, par:SfExpr):haxe.macro.Type {
		switch (par.def) {
			case SfVarDecl(v, _): return v.type;
			case SfBinop(OpAssign, a, _): return a.getTypeNz();
			case SfCall(_.def => SfInstField(_, f) | SfStaticField(_, f), callArgs): {
				var ind = callArgs.indexOf(orig);
				var f_args = f.args;
				if (ind >= 0 && ind < f_args.length) {
					return f_args[ind].v.type;
				}
			};
			case SfReturn(true, _): {
				if (currentExprFunc != null) {
					return currentExprFunc.ret;
				}
				if (currentField == null) return null;
				return currentField.type;
			}
			case SfArrayDecl(_): {
				switch (par.getTypeNz()) {
					case TInst(_.get() => { module: "Array" }, [t]): return t;
					default:
				}
			};
			case SfCast(_, t): return par.getTypeNz();
			default: {
				//trace(par, par.getType());
			};
		}
		return null;
	}
	
	function implStruct(e:SfExpr, st:SfExprList, at:SfAnon, fields:Array<{name:String, expr:SfExpr}>) {
		var fieldCount = fields.length;
		for (sf in at.fields) {
			switch (sf.type) {
				case TAbstract(_.get() => { module: "StdTypes", name: "Null" }, _): {}; // OK!
				default: continue;
			}
			//
			var name = sf.name;
			var i = -1;
			while (++i < fieldCount) {
				if (fields[i].name == name) break;
			}
			if (i >= fieldCount) {
				// we do not modify fieldCount so that we don't go over null-fields afterwards
				fields.push({ name: name, expr: e.mod(SfConst(TNull)) });
			}
		}
	}
	
	function implArray(e:SfExpr, st:SfExprList, at:SfAnon, fields:Array<{name:String, expr:SfExpr}>) {
		var idm = at.indexMap;
		var prev = st[0];
		var args:Array<SfExpr>;
		var legacyMeta = sfConfig.legacyMeta;
		
		//
		if ((at.nativeGen || !legacyMeta) && hasArrayDecl) { // {...} -> [...]
			args = [];
			var size = at.indexes, i:Int;
			i = size; while (--i >= 0) args.push(null);
			var ok = true;
			i = -1; // index of last non-simple value
			for (pair in fields) {
				var k = idm.get(pair.name);
				var px = pair.expr;
				if (!px.isSimple()) {
					if (k < i) {
						// you know, I was worried that this would cause problems in cases where
						// order of operations matters, but GML already causes a ton of problems
						// due to evaluating arguments LTR/RTL depending on target platform.
						//ok = false;
						break;
					} else i = k;
				}
				if (hint) px = px.mod(SfDynamic("/* " + pair.name + ": */{0}", [px]));
				args[k] = px;
			}
			if (ok) {
				i = size;
				while (--i >= 0) if (args[i] == null) {
					var px = e.mod(SfConst(TNull));
					if (hint) px = px.mod(SfDynamic("/* " + at.fields[i].name + ": */{0}", [px]));
					args[i] = px;
				}
				e.def = SfArrayDecl(args);
				return;
			}
		}
		
		//
		var targetVar:SfVar = switch (prev.def) {
			case SfVarDecl(v, _): v;
			case SfBinop(OpAssign, _.def => SfLocal(v), _): v;
			default: null;
		};
		if (targetVar != null) {
			var isVarDecl = prev.def.match(SfVarDecl(_, _, _));
			var targetVarExpr = prev.mod(SfLocal(targetVar));
			var rb:Array<SfExpr> = [];
			var modern = sfConfig.hasArrayCreate;
			
			// `obj = array_create(<size of T>)`:
			var resetExpr:SfExpr;
			if (modern) {
				var args:Array<SfExpr> = [prev.mod(SfConst(TInt(at.indexes)))];
				if (sfConfig.hasArrayDecl) {
					// initialize with `undefined` if available:
					args.push(prev.mod(SfConst(TNull)));
				}
				var alloc = prev.mod(SfIdent("array_create"));
				resetExpr = prev.mod(SfCall(alloc, args));
			} else resetExpr = prev.mod(SfConst(TNull));
			
			// `var obj = ...` or `obj = ...`
			if (isVarDecl) {
				rb.push(prev.mod(SfVarDecl(targetVar, true, resetExpr)));
			} else {
				rb.push(prev.mod(SfBinop(OpAssign, targetVarExpr, resetExpr)));
			}
			
			// tag non-nativeGen abstracts with metadata:
			if (!at.nativeGen && legacyMeta) {
				var arr = sfGenerator.typeArray;
				rb.push(prev.mod(SfDynamic("{0}[1,0] = {1}", [
					targetVarExpr.clone(),
					prev.mod(SfConst(TString(at.name)))
				])));
			}
			
			//
			var last:Int = at.indexes - 1, addb:SfBuffer;
			inline function add(i:Int, x:SfExpr, ?s:String) {
				addb = new SfBuffer();
				addb.addString("{0}[");
				if (s != null) {
					at.printAnonFieldTo(addb, s, i);
				} else addb.addInt(i);
				addb.addChar("]".code);
				rb.push(prev.mod(SfBinop(OpAssign,
					prev.mod(SfDynamic(addb.toString(), [
						targetVarExpr.clone(),
					])), x
				)));
			}
			
			var excl = null, fx:SfExpr, fs:String;
			if (!modern) {
				for (f in fields) {
					fs = f.name;
					if (idm[fs] == last) {
						fx = f.expr;
						if (fx.isSimple() || fields[0] == f) {
							add(last, fx, fs);
							excl = f;
						}
						break;
					}
				}
				if (excl == null) add(last, e.mod(SfConst(TInt(0))));
			}
			//
			for (f in fields) if (f != excl) {
				fx = f.expr; fs = f.name;
				if (idm.exists(fs)) {
					add(idm[fs], fx, fs);
				} else fx.error('Field $fs is not present in ${at.name}.');
			}
			
			if (rb.length == 1) {
				prev.setTo(rb[0].def);
				return;
			}
			// prefer `var x = {a:1, b: 2}; return x;`
			// -> `var x = array_create(2); x[0] = 1; x[1] = 2; return x;`
			// instead of technically putting the variable declaration in a lonely block
			if (st.length > 1) switch (st[1].def) {
				case SfBlock(p1x): {
					var insertAt = p1x.indexOf(prev);
					if (insertAt >= 0) {
						p1x.splice(insertAt, 1);
						for (i in 0 ... rb.length) {
							p1x.insert(insertAt + i, rb[i]);
						}
						return;
					}
				};
				default:
			}
			prev.setTo(SfBlock(rb));
			return;
		}
		
		// -> odecl("tag", sizeof, ...pairs)
		args = [
			e.mod(SfConst(TString(at.name))),
			e.mod(SfConst(TInt(at.indexes))),
		];
		for (f in fields) if (idm.exists(f.name)) {
			args.push(e.mod(SfConst(TInt(idm.get(f.name)))));
			args.push(f.expr);
		} else f.expr.error('Field ${f.name} is not present in ${at.name}.');
		e.def = SfCall(e.mod(SfStaticField(bootClass, odeclField)), args);
		odeclUsed = true;
	}
	
	function implOuter(e:SfExpr, st:SfExprList):Void {
		var fields = switch (e.def) {
			case SfObjectDecl(_fields): _fields;
			default: return;
		};
		
		// figure out the type:
		var t = e.getType();
		switch (t) {
			case TAnonymous(_): {
				if (st.length > 0) {
					t = getTypeFromParent(e, st[0]);
				} else if (currentField != null) {
					t = currentField.type; // public var field = { ... }
				}
			};
			default:
		}
		if (t == null) return;
		
		// look up the typedef:
		inline function lookup(dt:DefType) {
			return sfGenerator.anonMap.baseGet(dt);
		}
		var at:SfAnon = switch (t) {
			case TType(_.get() => dt, _): lookup(dt);
			case TAbstract(_.get() => { type: TType(_.get() => dt, _) }, _): lookup(dt);
			default: null;
		};
		if (at == null) return;
		
		if (at.isDsMap) {
			var args = [];
			for (f in fields) {
				args.push(e.mod(SfConst(TString(f.name))));
				args.push(f.expr);
			}
			if (mdeclField == null) {
				e.error("js.Boot.mdecl is amiss - try referencing it");
				return;
			}
			e.def = SfCall(e.mod(SfStaticField(bootClass, mdeclField)), args);
			mdeclUsed = true;
		} else if (at.isStruct) {
			implStruct(e, st, at, fields);
		} else {
			implArray(e, st, at, fields);
		}
	}
	
	override public function apply() {
		bootClass = sfGenerator.typeBoot;
		if (bootClass != null) {
			odeclField = bootClass.staticMap["odecl"];
			mdeclField = bootClass.staticMap["mdecl"];
		}
		hasArrayDecl = sfConfig.hasArrayDecl;
		hint = sfConfig.hint;
		//
		forEachExpr(function(e:SfExpr, st, f:SfExprIter) {
			implOuter(e, st);
			switch (e.def) {
				case SfFunction(ef):
					var ef0 = currentExprFunc;
					
					st.unshift(e);
					currentExprFunc = ef;
					
					f(currentExprFunc.expr, st, f);
					
					currentExprFunc = ef0;
					st.shift();
				default:
					e.iter(st, f);
			}
		}, []);
		//
		if (!odeclUsed && odeclField != null) bootClass.removeField(odeclField);
		if (!mdeclUsed && mdeclField != null) bootClass.removeField(mdeclField);
	}
	
}
