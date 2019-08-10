package sf.opt;

import haxe.macro.Expr.Binop;
import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * GML is yet to allow chained array access (a[0][1] = x), therefore it can be necessary
 * to convert to array_wset(a[0], 1, x) instead.
 * @author YellowAfterlife
 */
class SfGmlArrayAccess extends SfOptImpl {
	
	/** Returns whether wrapping is needed for array access on e. */
	public static function needsWrapping(e:SfExpr):Bool {
		return switch (e.unpack().def) {
			case SfConst(_): false;
			case SfDynamic(s, _): s.indexOf("[") >= 0;
			case SfLocal(_): false;
			case SfStaticField(_, _): false;
			case SfInstField(_, f): f.index >= 0;
			default: true;
		}
	}
	
	public static var wget:SfClassField;
	public static var wgetUsed:Bool;
	public static var wset:SfClassField;
	public static var wsetUsed:Bool;
	static function check(e:SfExpr, w, f) {
		inline function nw(e:SfExpr):Bool {
			return needsWrapping(e);
		}
		inline function mod(d:SfExprDef):SfExpr {
			return e.mod(d);
		}
		//
		var aop:Binop;
		inline function setAop(op:Binop):Void {
			aop = switch (op) {
				case OpAssignOp(o): o;
				default: null;
			};
		}
		//
		inline function checkSideEffects(e:SfExpr):Void {
			if (!e.isSimple()) {
				e.warning("[SfGmlArrayAccess] Due to expression duplication to workaround lack of accessor chaining, this may have side effects." + e.getName());
			}
		}
		//
		switch (e.def) {
			case SfBinop(q = OpAssign | OpAssignOp(_),
				x = _.def => SfArrayAccess(o, i),
			v) if (nw(o)): { // a[i] = v
				setAop(q);
				if (aop != null) {
					e.setTo(SfCall(mod(SfInstField(o, wset)), [i,
						mod(SfBinop(aop, x.clone(), v))
					]));
				} else e.setTo(SfCall(mod(SfInstField(o, wset)), [i, v]));
				wsetUsed = true;
			};
			case SfArrayAccess(o, i) | SfEnumAccess(o, _, i) if (nw(o)): { // a[i]
				e.setTo(SfCall(mod(SfInstField(o, wget)), [i]));
				wgetUsed = true;
			};
			case SfEnumParameter(o, _, i) if (nw(o)): {
				e.setTo(SfCall(mod(SfInstField(o, wget)), [
					mod(SfConst(TInt(i + 1)))
				]));
				wgetUsed = true;
			};
			case SfBinop(q = OpAssign | OpAssignOp(_),
				x = _.def => SfDynamicField(o, s),
			v) if (nw(o)): {
				switch (o.getTypeNz()) {
					case TType(_.get() => dt, _): {
						var at = sfGenerator.anonMap.baseGet(dt);
						if (at != null) {
							setAop(q);
							var cfi:SfExpr;
							if (at.isDsMap) {
								cfi = mod(SfConst(TString(s)));
								if (aop != null) {
									checkSideEffects(o);
									e.setTo(SfCall(mod(SfDynamic("ds_map_set", [])), [
										o, cfi, mod(SfBinop(aop, x.clone(), v))
									]));
								} else e.setTo(SfCall(mod(SfDynamic("ds_map_set", [])), [
									o, cfi, v
								]));
							} else if (at.indexMap.exists(s)) {
								cfi = mod(SfConst(TInt(at.indexMap.get(s))));
								if (aop != null) {
									checkSideEffects(o);
									e.setTo(SfCall(mod(SfInstField(o, wset)), [
										cfi, mod(SfBinop(aop, x.clone(), v))
									]));
								} else e.setTo(SfCall(mod(SfInstField(o, wset)), [cfi, v]));
								wsetUsed = true;
							}
						}
					};
					default:
				}
			};
			case SfDynamicField(o, s) if (nw(o)): {
				switch (o.getTypeNz()) {
					case TType(_.get() => dt, _): {
						var at = sfGenerator.anonMap.baseGet(dt);
						if (at != null) {
							if (at.isDsMap) {
								e.setTo(SfCall(mod(SfDynamic("ds_map_find_value", [])), [
									o, mod(SfConst(TString(s)))
								]));
							} else if (at.indexMap.exists(s)) {
								e.setTo(SfCall(mod(SfInstField(o, wget)),
									[mod(SfConst(TInt(at.indexMap.get(s))))]));
								wgetUsed = true;
							}
						}
					};
					default:
				}
			};
			case SfBinop(q = OpAssign | OpAssignOp(_),
				x = _.def => SfInstField(o, cf), v
			) if (cf.index >= 0 && nw(o)): { // c.f = v
				var cfi:SfExpr = mod(SfConst(TInt(cf.index)));
				switch (q) {
					case OpAssignOp(aop): {
						checkSideEffects(o);
						e.setTo(SfCall(mod(SfInstField(o, wset)), [cfi,
							mod(SfBinop(aop, x.clone(), v))
						]));
					};
					default: {
						e.setTo(SfCall(mod(SfInstField(o, wset)), [cfi, v]));
					};
				}
				wsetUsed = true;
			};
			case SfInstField(o, cf) if (cf.index >= 0 && nw(o)): { // c.f
				e.setTo(SfCall(mod(SfInstField(o, wget)), [
					mod(SfConst(TInt(cf.index)))
				]));
				wgetUsed = true;
			}
			default:
		}
		e.iter(w, f);
	}
	
	override public function apply() {
		var atype = sfGenerator.typeBoot;
		// change array.length to array_length_1d(array) because Haxe doesn't:
		var flen = sfGenerator.typeArray.fieldMap.get("length");
		forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfInstField(x, q) if (q == flen): {
					e.def = SfCall(e.mod(SfDynamic("array_length_1d", [])), [x]);
				};
				default:
			}
		});
		//
		wget = atype.fieldMap.get("wget");
		if (wget == null) throw "Array has no wget";
		wgetUsed = matchEachExpr(function(e:SfExpr, w, f) {
			return switch (e.def) {
				case SfInstField(_, f) if (f == wget): true;
				default: e.matchIter(w, f);
			}
		});
		wset = atype.fieldMap.get("wset");
		if (wset == null) throw "Array has no wset";
		wsetUsed = matchEachExpr(function(e:SfExpr, w, f) {
			return switch (e.def) {
				case SfInstField(_, f) if (f == wset): true;
				default: e.matchIter(w, f);
			}
		});
		//
		forEachExpr(check);
		if (!wgetUsed) atype.removeField(wget);
		if (!wsetUsed) atype.removeField(wset);
	}
}
