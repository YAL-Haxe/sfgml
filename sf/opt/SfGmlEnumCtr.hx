package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
import sf.type.SfTypeMap;
using sf.type.SfExprTools;
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
		var clType:SfClass = cast sfGenerator.realMap["Type"];
		if (clType == null) return;
		var fdEnumConstructor = clType.fieldMap["enumConstructor"];
		if (fdEnumConstructor == null) return;
		var found = new SfTypeMap<String>();
		var out = new SfBuffer();
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var fdArrayDecl = sfGenerator.typeBoot.staticMap["decl"];
		forEachExpr(function(e:SfExpr, w:SfExprList, f:SfExprIter) {
			e.iter(w, f);
			switch (e.def) {
				case SfCall(_.def => SfStaticField(c, f), [v]) if (
					c == clType && f == fdEnumConstructor
				): {
					switch (v.getType()) {
						case TEnum(_.get() => et, _): {
							var sfEnum:SfEnum = sfGenerator.enumMap.baseGet(et);
							if (sfEnum != null && sfEnum.nativeGen) {
								var namesPath = found.sfGet(sfEnum);
								if (namesPath == null) {
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
										printf(out, '"%(field_auto)"', ctr);
									}
									out.addChar(hasArrayDecl ? "]".code : ")".code);
									printf(out, ";\n");
								}
								e.setTo(SfArrayAccess(
									e.mod(SfDynamic(namesPath, [])),
									e.mod(SfEnumAccess(v, sfEnum, e.mod(SfConst(TInt(0)))))
								));
							}
						};
						default:
					}
				};
				default:
			}
		});
		code = out.toString();
	}
}
