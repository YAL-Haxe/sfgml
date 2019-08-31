package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.type.SfTypeMap;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * If an enum is @:nativeGen, it has no metadata to get constructor name form.
 * However, when we know what enum instance it is, we can include the field names
 * separately and then transform v.getName() to Enum_Some_names[v.index]
 * @author YellowAfterlife
 */
class SfGmlEnumCtr extends SfOptImpl {
	public static var code:String = null;
	override public function apply() {
		code = "";
		//
		var clType:SfClass = cast sfGenerator.realMap["Type"];
		if (clType == null) return;
		var fdEnumConstructor = clType.realMap["enumConstructor"];
		var fdGetEnumConstructs = clType.realMap["getEnumConstructs"];
		if (fdEnumConstructor == null && fdGetEnumConstructs == null) return;
		var usesEnumConstructor = false;
		var usesGetEnumConstructs = false;
		//
		var found = new SfTypeMap<String>();
		var out = new SfBuffer();
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var fdArrayDecl = sfGenerator.typeBoot.realMap["decl"];
		function ensureNames(sfEnum:SfEnum):String {
			var namesPath = found.sfGet(sfEnum);
			if (namesPath == null) {
				// bit of a hack: this runs before SfGmlSnakeCase,
				// so we'll need to process the enum earlier on.
				SfGmlSnakeCase.procEnum(sfEnum);
				namesPath = {
					var b = new SfBuffer();
					printf(b, "g_%(type_auto)_names", sfEnum);
					b.toString();
				};
				found.sfSet(sfEnum, namesPath);
				printf(out, "globalvar %s;`", namesPath);
				printf(out, "%s`=`", namesPath);
				if (!hasArrayDecl) {
					out.addFieldPathAuto(fdArrayDecl);
					out.addChar("(".code);
				} else out.addChar("[".code);
				var sep = false;
				for (ctr in sfEnum.ctrList) {
					if (sep) printf(out, ",`"); else sep = true;
					printf(out, '"%s"', ctr.name);
				}
				out.addChar(hasArrayDecl ? "]".code : ")".code);
				printf(out, ";\n");
			}
			return namesPath;
		}
		forEachExpr(function(e:SfExpr, w:SfExprList, f:SfExprIter) {
			e.iter(w, f);
			switch (e.def) {
				case SfCall(_.def => SfStaticField(c, f), [v]) if (
					c == clType && f == fdGetEnumConstructs && fdGetEnumConstructs != null
				): {
					switch (v.unpack().def) {
						case SfTypeExpr(t) if (Std.is(t, SfEnum)): {
							var sfEnum:SfEnum = cast t;
							var def = SfDynamic(ensureNames(sfEnum), []);
							var sfArrayImpl:SfClass = cast sfGenerator.realMap["ArrayImpl"];
							var fdCopy = sfArrayImpl != null ? sfArrayImpl.realMap["copy"] : null;
							if (fdCopy != null) {
								def = SfCall(e.mod(SfStaticField(sfArrayImpl, fdCopy)), [e.mod(def)]);
							} else e.warning("Can't find Array.slice for getEnumConstructs");
							e.setTo(def);
						};
						default: {
							if (currentClass.module != "haxe.EnumTools") {
								usesGetEnumConstructs = true;
							}
						}
					}
				};
				case SfCall(_.def => SfStaticField(c, f), [v]) if (
					c == clType && f == fdEnumConstructor && fdEnumConstructor != null
				): {
					switch (v.getType()) {
						case TEnum(_.get() => et, _): {
							var sfEnum:SfEnum = sfGenerator.enumMap.baseGet(et);
							if (sfEnum != null && sfEnum.nativeGen) {
								var namesPath = ensureNames(sfEnum);
								if (!sfEnum.isFake) {
									v = e.mod(SfEnumAccess(v, sfEnum, e.mod(SfConst(TInt(0)))));
								}
								e.setTo(SfArrayAccess(e.mod(SfDynamic(namesPath, [])), v));
							}
						};
						default: usesEnumConstructor = true;
					}
				};
				default:
			}
		});
		if (!usesEnumConstructor && fdEnumConstructor != null) fdEnumConstructor.isHidden = true;
		if (!usesGetEnumConstructs && fdGetEnumConstructs != null) fdGetEnumConstructs.isHidden = true;
		code = out.toString();
	}
}
