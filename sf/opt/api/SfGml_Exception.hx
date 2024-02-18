package sf.opt.api;

import sf.type.expr.SfExpr;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGml_Exception extends SfOptImpl {
	function checkThrowString(e:SfExpr, _Exception:SfType):Bool {
		var throwExpr = switch (e.def) {
			case SfThrow(e): e;
			default: return false;
		}
		throwExpr = throwExpr.unpack();
		var arg = switch (throwExpr.def) {
			case SfCall(
				_.def => SfStaticField(c = { realName: "Exception" }, { realName: "thrown" }),
				[arg]
			) if (c == _Exception): arg;
			default: return false;
		}
		switch (arg.getType()) {
			case TInst(_.get() => { module: "String", pack: [] }, []): // OK!
			default: return false;
		}
		e.def = SfCall(
			e.mod(SfDynamic("show_error", [])),
			[arg, e.mod(SfConst(TBool(true)))]
		);
		return true;
	}
	override public function apply() {
		// where'd you come from
		var _MacroError = sfGenerator.realMap["haxe.macro.Error"];
		if (_MacroError != null) {
			_MacroError.isHidden = true;
		}
		//
		var _Exception = sfGenerator.realMap["haxe.Exception"];
		if (_Exception == null) return;
		forEachExpr(function(e:SfExpr, st, fn) {
			e.iter(st, fn);
			if (checkThrowString(e, _Exception)) return;
			switch (e.def) {
				case SfCall(
					_.def => SfStaticField(c = { realName: "Exception" }, { realName: "thrown" }),
					[arg]
				) if (c == _Exception): {
					switch (arg.getType()) {
						case TAbstract(_.get() => {
							module: "StdTypes",
							name: "String",
						}, []): {
							// throw "str" -> show_error("str", true)
							e.def = SfCall(
								e.mod(SfDynamic("show_error", [])),
								[arg, e.mod(SfConst(TBool(true)))]
							);
						};
						default:
					}
				};
				default:
			}
		});
	}
}