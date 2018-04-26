package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * Mapping SfInstanceOf(expr, Type) to context-specific GML functions.
 * @author YellowAfterlife
 */
class SfGmlInstanceOf extends SfOptImpl {
	
	/** Whether any occurences of Std.is remain in code */
	public static var isUsed:Bool;
	
	override public function apply() {
		var used = null;
		var sfg = sfGenerator;
		var stdType = sfg.classMap.get("Std", "");
		var stdIsType = sfg.classMap.get("Std", "is");
		var stdIsField = stdIsType != null ? stdIsType.staticMap.get("type") : null;
		forEachExpr(function(e:SfExpr, w, f:SfExprIter) {
			e.iter(w, f);
			switch (e.def) {
				case SfInstanceOf(x, t): {
					switch (t.def) {
						case SfTypeExpr(sft): {
							inline function isfn(s:String) {
								e.def = SfCall(e.mod(SfDynamic(s, [])), [x]);
							}
							switch (sft.realPath) {
								case "String": isfn("is_string");
								case "Float": isfn("is_real");
								case "Bool": isfn("is_bool");
								case "Array": isfn("is_array");
								case "haxe.Int64": isfn("is_int64");
								case "Int": {
									// `(is_real(x) && (x | 0 == x))`:
									e.def = SfParenthesis(e.mod(SfBinop(OpBoolAnd,
											e.mod(SfCall(e.mod(SfDynamic("is_real", [])),
												[x]
											)),
											e.mod(SfParenthesis(e.mod(SfBinop(OpEq,
													e.mod(SfBinop(OpOr, x,
														e.mod(SfConst(TInt(0)))
													)), x
												))
											))
										))
									);
								};
								default: {
									e.def = SfCall(e.mod(SfStaticField(stdIsType, stdIsField)),
										[x, t]
									);
									if (stdType == null || currentClass != stdType) used = e;
								};
							}
						};
						default:
					}
				};
				case SfStaticField(c, f): {
					if (stdIsType != null && c == stdIsType && f == stdIsField
						&& (stdType == null || currentClass != stdType)
					) used = e;
				}
				default:
			}
		});
		isUsed = used != null;
		if (used == null && stdIsType != null) stdIsType.removeField(stdIsField);
	}
	
}
