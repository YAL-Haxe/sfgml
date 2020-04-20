package sf.opt.type;
import haxe.macro.Type;
import sf.type.SfTypeMap;

/**
 * If -D sfgml-hint-var-types is set, we can include comments about what types
 * the local variables are.
 * @author YellowAfterlife
 */
class SfGmlTypeHint {
	
	static inline var metaName:String = ":hintType";
	static var cache:SfTypeMap<String> = new SfTypeMap();
	static function extract(bt:BaseType):Null<String> {
		if (!bt.meta.has(metaName)) return null;
		var entry = bt.meta.extract(metaName)[0];
		if (entry == null) return null;
		var param = entry.params != null ? entry.params[0] : null;
		if (param == null) return null;
		switch (param.expr) {
			case EConst(CString(s)): return s;
			default: return null;
		}
	}
	static function getc(ct:ClassType) {
		var r = cache.baseGet(ct);
		if (r != null) return r;
		r = extract(ct);
		if (r == null && ct.superClass != null) {
			r = getc(ct.superClass.t.get());
		}
		if (r == null) r = "";
		cache.baseSet(ct, r);
		return r;
	}
	public static function get(t:Type):Null<String> {
		var r:String = null;
		switch (t) {
			case TAbstract(_.get() => at, _): {
				switch (at.module) {
					case "StdTypes": switch (at.name) {
						case "Int": return "int32";
						case "Float": return "double";
						case "Bool": return "bool";
						case "Null": return null;
					};
					default: {
						r = cache.baseGet(at);
						if (r == null) {
							r = extract(at);
							if (r == null) r = get(at.type);
							if (r == null) r = "";
							cache.baseSet(at, r);
						}
					};
				}
			};
			case TInst(_.get() => ct, _): r = getc(ct);
			case TType(_.get() => tt, _): {
				r = cache.baseGet(tt);
				if (r == null) {
					r = extract(tt);
					if (r == null) r = get(tt.type);
					if (r == null) r = "";
					cache.baseSet(tt, r);
				}
			};
			case TMono(_.get() => t): r = (t != null ? get(t) : null);
			case TEnum(_.get() => et, _): {
				r = cache.baseGet(et);
				if (r == null) {
					r = extract(et);
					if (r == null) r = "";
					cache.baseSet(et, r);
				}
			};
			case TFun(_, _): r = null;
			case TLazy(f): r = get(f());
			case TAnonymous(_): r = null;
			case TDynamic(_): r = null;
		}
		return r != "" ? r : null;
	}
}
