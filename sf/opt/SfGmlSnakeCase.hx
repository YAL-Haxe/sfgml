package sf.opt;

import haxe.macro.Expr.Binop;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlSnakeCase extends SfOptImpl {
	/**
	 * Converts a string from camelCase to snake_case.
	 */
	public static function toSnakeCase(s:String):String {
		var n = s.length;
		// early exit if the string is already in snake_case:
		var i = -1;
		while (++i < n) {
			var c = StringTools.fastCodeAt(s, i); // or s.charCodeAt(i)
			if (c >= "A".code && c <= "Z".code) break;
		}
		if (i >= n) return s;
		// otherwise form it via a string buffer:
		var r = new StringBuf();
		var p = 0;
		for (i in 0 ... n) {
			var c = StringTools.fastCodeAt(s, i);
			if (c >= "A".code && c <= "Z".code) {
				if (p >= "a".code && p <= "z".code
				 || p >= "0".code && p <= "9".code) { // "eC" -> "e_c"
					r.addChar("_".code);
				}
				r.addChar(c + ("a".code - "A".code));
			} else r.addChar(c);
			p = c;
		}
		return r.toString();
	}
	public static function checkType(q:SfType):Bool {
		return q.meta.has(":snakeCase")
			// with -D sfgml_snake_case, we don't touch extern and/or std classes
			|| (sfConfig.snakeCase && !(q.isHidden || q.meta.has(":std")));
	}
	public static function applyToType(q:SfType):Void {
		if (!q.meta.has(":native") && !q.meta.has(":expose")) {
			var qp = q.pack;
			for (i in 0 ... qp.length) qp[i] = toSnakeCase(qp[i]);
			q.name = toSnakeCase(q.name);
		}
	}
	public static function procClass(c:SfClass) {
		var apply = checkType(c);
		if (!apply && c.meta.has(":enum")) do {
			// Abstracts are named like com.pkg.Some,
			// and their implementation classes are named like com.pkg._Outer.Thing_Impl_
			// but most of metadata doesn't transfer to impl-class,
			// so we need to parse the realPath and resolve the abstract
			var path = c.realPath;
			if (!StringTools.endsWith(path, "_Impl_")) break;
			var dot = path.lastIndexOf(".");
			if (dot < 0) break;
			var dot2 = path.lastIndexOf(".", dot - 1);
			path = path.substring(0, dot2 + 1) + path.substring(dot + 1, path.length - 6);
			//
			var sfa = sfGenerator.realMap[path];
			if (sfa == null) break;
			apply = checkType(sfa);
		} while (false);
		if (apply) {
			applyToType(c);
			for (f in c.fieldList) {
				if (!f.meta.has(":native") && !f.meta.has(":expose")) {
					c.renameField(f, toSnakeCase(f.name));
				}
			}
		}
	}
	public static function procEnum(e:SfEnum) {
		if (checkType(e)) {
			applyToType(e);
			for (f in e.ctrList) {
				if (!f.meta.has(":native") && !f.meta.has(":expose")) {
					f.name = toSnakeCase(f.name);
				}
			}
		}
	}
	public static function procAnon(a:SfAnon):Void {
		if (a.meta.has(":snakeCase")) {
			applyToType(a);
			for (f in a.fields) {
				if (!f.meta.has(":native") && !f.meta.has(":expose")) {
					f.name = toSnakeCase(f.name);
				}
			}
		}
	}
	
	override public function apply():Void {
		for (c in sfGenerator.classList) procClass(c);
		for (e in sfGenerator.enumList) procEnum(e);
		for (a in sfGenerator.anonList) procAnon(a);
	}
}
