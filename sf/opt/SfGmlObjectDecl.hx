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
		var field = type.staticMap["odecl"];
		if (field == null) {
			Sys.println("No `odecl` field?");
			return;
		}
		var used = false;
		var xm = sfConfig.gmxMode;
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
				switch (t) {
					case TType(_.get() => dt, _): {
						var at = sfGenerator.anonMap.baseGet(dt);
						if (at != null) { // a known typedef
							var idm = at.indexMap;
							var found = false;
							var prev = w[0];
							if (prev != null) switch (prev.def) {
								case SfVarDecl(v, _)
								| SfBinop(OpAssign, _.def => SfLocal(v), _)
								: {
									var rb:Array<SfExpr> = [];
									var modern = sfConfig.version < 0 || sfConfig.version > 1763;
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
							if (!found) {
								var args:Array<SfExpr> = [
									e.mod(SfConst(TString(dt.name))),
									e.mod(SfConst(TInt(at.indexes))),
								];
								for (f in fields) if (idm.exists(f.name)) {
									args.push(e.mod(SfConst(TInt(idm.get(f.name)))));
									args.push(f.expr);
								} else f.expr.error('Field ${f.name} is not present in ${at.name}.');
								e.def = SfCall(e.mod(SfStaticField(type, field)), args);
								used = true;
							};
						}
					};
					default:
				}
				e.iter(w, f);
			}
			default: e.iter(w, f);
			}
		}, []);
		if (!used) type.removeField(field);
	}
	
}
