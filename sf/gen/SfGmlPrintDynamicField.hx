package sf.gen;
import haxe.macro.Expr.Binop;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import sf.SfGenerator;
import sf.type.SfAnon;
import sf.type.SfBuffer;
import sf.type.expr.SfExpr;
import sf.type.expr.SfExprDef.*;
import sf.type.SfClass;
import sf.SfCore.*;
import sf.type.SfPrintFlags;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlPrintDynamicField {
	public static function resolve(t:Type):SfGmlPrintDynamicFieldResolution {
		for (i in 0 ... 8) {
			//trace(t);
			inline function follow(){
				t = TypeTools.followWithAbstracts(t, true);
			}
			switch (t) {
				case null: return RNone;
				case TAbstract(_.get() => at, p):
					if (at.name == "Null") {
						t = p[0];
					} else follow();
				case TType(_.get() => dt, p):
					var a = sfGenerator.anonMap.baseGet(dt);
					if (a != null) return RAnon(a);
					follow();
				case TInst(_.get() => ct, p):
					var c = sfGenerator.classMap.baseGet(ct);
					if (c != null) return RClass(c);
					return RNone;
				default: return RNone;
			}
		}
		return RNone;
	}
	public static function checkPrintStatic(r:SfBuffer, obj:SfExpr, fieldName:String) {
		switch (obj.def) {
			case SfTypeExpr(t) if (t is SfClass): {
				var fd = (cast t:SfClass).fieldMap[fieldName];
				if (fd != null) {
					r.addFieldPathAuto(fd);
					return true;
				}
			};
			default:
		}
		return false;
	}
	static function checkPrintShared(r:SfBuffer,
		rr:SfGmlPrintDynamicFieldResolution,
		expr:SfExpr, obj:SfExpr, fieldName:String, ?op:Binop, ?val:SfExpr
	) {
		inline function printOpVal() {
			if (val != null) {
				@:privateAccess sfGenerator.printSetOp(r, op, expr);
				r.addExpr(val, SfPrintFlags.ExprWrap);
			}
		}
		switch (rr) {
			case RAnon(qt) if (qt.isDsMap): {
				var mfd = qt.fieldMap[fieldName];
				var key = mfd != null ? mfd.name : fieldName;
				#if sfgml_no_accessors
				if (val != null) {
					if (op == OpAssign) {
						printf(r, 'ds_map_set(%x, "%s", %x)', obj, key, val);
					} else expr.error('Can\'t do a $op without accessors');
				} else printf(r, 'ds_map_find_value(%x, "%s")', obj, key);
				#else
				printf(r, '%x[?"%s"]', obj, key);
				printOpVal();
				#end
				return true;
			};
			case RAnon(qt) if (qt.dotAccess): {
				printf(r, '%x.%s', obj, fieldName);
				printOpVal();
				return true;
			};
			case RAnon(qt) if (qt.indexMap.exists(fieldName)): {
				printf(r, "%x[%s", obj, val != null ? "@" : "");
				qt.printAnonFieldTo(r, fieldName, qt.indexMap[fieldName]);
				printf(r, "]");
				printOpVal();
				return true;
			};
			case RClass(c): {
				if (c.dotAccess) {
					printf(r, "%x.%s", obj, fieldName);
					printOpVal();
					return true;
				} else {
					var cf = c.instMap[fieldName];
					if (cf != null) {
						if (cf.index >= 0) {
							printf(r, "%x[%s%d%(hint)]", obj, val != null ? "@" : "", cf.index, fieldName);
							printOpVal();
							return true;
						} else expr.error("Field " + fieldName + " has no index.");
					}
				}
			};
			default:
		}
		return false;
	}
	public static function getter(gen:SfGenerator, r:SfBuffer, expr:SfExpr, obj:SfExpr, fieldName:String) {
		if (checkPrintStatic(r, obj, fieldName)) return;
		var rr = resolve(obj.getType());
		if (checkPrintShared(r, rr, expr, obj, fieldName, null)) return;
		
		if (sfConfig.modern) {
			printf(r, "%x.%s", obj, fieldName);
		} else {
			expr.error("[SfGmlPrintDynamicField:getter] Can't do dynamic field read on "
				+ SfExprTools.dump(expr) + " type " + obj.getType());
		}
	}
	public static function setter(gen:SfGenerator, r:SfBuffer, expr:SfExpr, obj:SfExpr, fieldName:String, op:Binop, val:SfExpr) {
		inline function printOpVal() {
			@:privateAccess gen.printSetOp(r, op, expr);
			r.addExpr(val, SfPrintFlags.ExprWrap);
		}
		if (checkPrintStatic(r, obj, fieldName)) {
			printOpVal();
			return;
		}
		var rr = resolve(obj.getType());
		if (checkPrintShared(r, rr, expr, obj, fieldName, op, val)) return;
		
		if (sfConfig.modern) {
			printf(r, "%x.%s", obj, fieldName);
			printOpVal();
		} else {
			expr.error("[SfGmlPrintDynamicField:setter] Can't do dynamic field write on "
				+ SfExprTools.dump(expr) + " type " + obj.getType());
		}
	}
}
enum SfGmlPrintDynamicFieldResolution {
	RNone;
	RAnon(qt:SfAnon);
	RClass(c:SfClass);
}