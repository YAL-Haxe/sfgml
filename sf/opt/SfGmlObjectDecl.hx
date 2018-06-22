package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * GML does not have lightweight anonymous objects yet, so anonymous structures with known
 * fields are compiled into array-based structures. Unwrapping is also handled here.
 * @author YellowAfterlife
 */
class SfGmlObjectDecl extends SfOptImpl {
	
	override public function apply() {
		var type:SfClass = sfGenerator.typeBoot;
		if (type == null) return;
		var odeclField = type.staticMap["odecl"];
		var odeclUsed = false;
		if (odeclField == null) {
			Sys.println("No `odecl` field?");
			return;
		}
		var mdeclField = type.staticMap["mdecl"];
		var mdeclUsed = false;
		if (mdeclField == null) {
			Sys.println("No `mdecl` field?");
			return;
		}
		var xm = sfConfig.gmxMode;
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var hint = sfConfig.hint;
		forEachExpr(function(e:SfExpr, w, f:SfExprIter) {
			switch (e.def) {
			case SfObjectDecl(fields): {
				var t = e.getType();
				switch (t) {
					case TAnonymous(_): {
						if (w.length > 0) {
							switch (w[0].def) {
								case SfVarDecl(v, _): t = v.type; // var v = { ... }
								case SfBinop(OpAssign, a, _): t = a.getType(); // a = { ... }
								default:
							}
						} else if (currentField != null) {
							t = currentField.type; // public var field = { ... }
						}
					};
					default:
				}
				var at:SfAnon = switch (t) {
					case TType(_.get() => dt, _): sfGenerator.anonMap.baseGet(dt);
					default: null;
				};
				if (at != null) {
					var idm = at.indexMap;
					var found = false;
					var prev = w[0];
					var args:Array<SfExpr>;
					if (at.isDsMap) { // -> mdecl(k1, v1, k2, v2, ...)
						args = [];
						for (f in fields) {
							args.push(e.mod(SfConst(TString(f.name))));
							args.push(f.expr);
						}
						e.def = SfCall(e.mod(SfStaticField(type, mdeclField)), args);
						mdeclUsed = true;
						found = true;
					}
					if (!found && at.nativeGen && hasArrayDecl) { // {...} -> [...]
						args = [];
						var size = at.indexes, i:Int;
						i = size; while (--i >= 0) args.push(null);
						found = true;
						i = -1; // index of last non-simple value
						for (pair in fields) {
							var k = idm.get(pair.name);
							var px = pair.expr;
							if (!px.isSimple()) {
								if (k < i) {
									found = false;
									break;
								} else i = k;
							}
							if (hint) {
								px = px.mod(SfDynamic("/* " + pair.name + ": */{0}", [px]));
							}
							args[k] = px;
						}
						if (found) {
							i = size;
							while (--i >= 0) if (args[i] == null) {
								args[i] = e.mod(SfConst(TNull));
							}
							e.def = SfArrayDecl(args);
						}
					}
					if (!found && prev != null) switch (prev.def) { // expand into block?
						case SfVarDecl(v, _)
						| SfBinop(OpAssign, _.def => SfLocal(v), _)
						: {
							var rb:Array<SfExpr> = [];
							var modern = sfConfig.hasArrayCreate;
							// `obj = array_create(<size of T>)`:
							var resetExpr = prev.mod(modern
								? SfDynamic("array_create(" + at.indexes + ")", [])
								: SfConst(TNull)
							);
							switch (prev.def) {
								case SfBinop(_, vx1, _): {
									rb.push(prev.mod(SfBinop(OpAssign, vx1, resetExpr)));
								};
								case SfVarDecl(v, _): {
									rb.push(prev.mod(SfVarDecl(v, true, resetExpr)));
								};
								default:
							}
							// tag non-nativeGen abstracts with metadata:
							if (!at.nativeGen) {
								var arr = sfGenerator.typeArray;
								rb.push(prev.mod(SfDynamic("{0}[1,0] = {1}", [
									prev.mod(SfLocal(v)),
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
										prev.mod(SfLocal(v))
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
							prev.setTo(SfBlock(rb));
							found = true;
						};
						default:
					}
					if (!found) { // -> odecl("tag", sizeof, ...pairs)
						args = [
							e.mod(SfConst(TString(at.name))),
							e.mod(SfConst(TInt(at.indexes))),
						];
						for (f in fields) if (idm.exists(f.name)) {
							args.push(e.mod(SfConst(TInt(idm.get(f.name)))));
							args.push(f.expr);
						} else f.expr.error('Field ${f.name} is not present in ${at.name}.');
						e.def = SfCall(e.mod(SfStaticField(type, odeclField)), args);
						odeclUsed = true;
					};
				}
				e.iter(w, f);
			}
			default: e.iter(w, f);
			}
		}, []);
		if (!odeclUsed) type.removeField(odeclField);
		if (!mdeclUsed) type.removeField(mdeclField);
	}
	
}
