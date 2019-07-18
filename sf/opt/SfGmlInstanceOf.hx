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
		var sfg = sfGenerator;
		
		// Std class is usually eliminated from AST, but, just in case it isn't, we want
		// a reference to it so that we can check that use of StdImpl.is isn't in Std.
		var _Std = sfg.classMap.get("Std", "");
		
		var _StdImpl:SfClass = cast sfg.realMap["_Std.StdImpl"];
		var _StdImpl_is = _StdImpl != null ? _StdImpl.realMap["is"] : null;
		var _StdImpl_is_usedBy:SfExpr = null;
		var _StdImpl_isNumber = _StdImpl != null ? _StdImpl.realMap["isNumber"] : null;
		var _StdImpl_isNumber_usedBy:SfExpr = null;
		var _StdImpl_isInt = _StdImpl != null ? _StdImpl.realMap["isInt"] : null;
		var _StdImpl_isInt_usedBy:SfExpr = null;
		
		forEachExpr(function(e:SfExpr, w, f:SfExprIter) {
			e.iter(w, f);
			switch (e.def) {
				case SfInstanceOf(x, t): {
					switch (t.def) {
						case SfTypeExpr(sft): {
							inline function isfn(s:String) {
								e.def = SfCall(e.mod(SfDynamic(s, [])), [x]);
							}
							inline function isfd(fd:SfClassField):Void {
								e.def = SfCall(e.mod(SfStaticField(_StdImpl, fd)), [x]);
							}
							switch (sft.realPath) {
								case "String": isfn("is_string");
								case "Float": {
									isfd(_StdImpl_isNumber);
									_StdImpl_isNumber_usedBy = e;
								};
								case "Int": {
									isfd(_StdImpl_isInt);
									_StdImpl_isInt_usedBy = e;
								};
								case "Bool": isfn("is_bool");
								case "Array": isfn("is_array");
								case "haxe.Int64": isfn("is_int64");
								default: {
									e.def = SfCall(e.mod(SfStaticField(_StdImpl, _StdImpl_is)),
										[x, t]
									);
									if (_Std == null || currentClass != _Std) _StdImpl_is_usedBy = e;
								};
							}
						};
						default:
					}
				};
				case SfStaticField(c, f): {
					if (_StdImpl != null && c == _StdImpl && f == _StdImpl_is
						&& (_Std == null || currentClass != _Std)
					) _StdImpl_is_usedBy = e;
				};
				default:
			}
		});
		isUsed = _StdImpl_is_usedBy != null;
		if (_StdImpl != null) {
			var warn = false;
			
			if (_StdImpl_is_usedBy != null) {
				if (warn) _StdImpl_is_usedBy.warning("Std.is is used by this expression");
			} else _StdImpl.removeField(_StdImpl_is);
			
			if (_StdImpl_isInt_usedBy != null) {
				if (warn) _StdImpl_isInt_usedBy.warning("Std.isInt is used by this expression");
			} else _StdImpl.removeField(_StdImpl_isInt);
			
			if (_StdImpl_isNumber_usedBy != null) {
				if (warn) _StdImpl_isNumber_usedBy.warning("Std.isNumber is used by this expression");
			} else _StdImpl.removeField(_StdImpl_isNumber);
		}
	}
	
}
