package sf.opt.syntax;

import haxe.ds.Map;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;

/**
 * If an argument is accessed once or not at all, we might as well strip it
 * @author YellowAfterlife
 */
class SfGmlArgs extends SfOptImpl {
	function proc(fdExpr:SfExpr, args:Array<SfArgument>, thisArg:Bool) {
		var argCount:Int = thisArg ? 1 : 0;
		//
		var argMap = new Map<String, SfGmlArgsData>();
		var argList:Array<SfGmlArgsData> = [];
		for (arg in args) {
			var v = arg.v;
			var d:SfGmlArgsData = {
				arg: arg,
				v: v,
				found: 0,
				index: argCount++,
				first: null,
				from: null
			};
			argMap[v.name] = d;
			argList.push(d);
		}
		if (argCount == 0) return;
		//
		function check(expr:SfExpr, stack:SfExprList, iter:SfExprIter) {
			switch (expr.def) {
				case SfLocal(v): {
					var d = argMap[v.name];
					if (d != null && d.v.equals(v)) {
						if (++d.found == 1) {
							d.first = expr;
							d.from = stack[0];
						}
					}
				};
				case SfFunction(f): {
					proc(f.expr, f.args, false);
				};
				default:
			}
			expr.iter(stack, iter);
		}
		check(fdExpr, [], check);
		//
		for (d in argList) {
			if (d.found == 0) {
				d.arg.hidden = true;
			} else if (d.arg.value != null) {
				// don't inline optional arguments
			} else if (d.found == 1) {
				var hide = false;
				if (d.from == null) {
					hide = true;
				} else switch (d.from.def) {
					case SfArrayAccess(_, _)
						|SfEnumAccess(_, _, _)
						|SfEnumParameter(_, _, _)
						|SfInstField(_, _)
						|SfDynamicField(_, _)
					: {};
					case SfDynamic(code, _) if (code.indexOf("[") >= 0): {};
					default: hide = true;
				}
				if (hide) {
					d.arg.hidden = true;
					d.first.def = SfDynamic("argument[" + d.index + "]", []);
				}
			}
		}
	}
	override public function apply():Void {
		if (sfConfig.modern) return; // we can just use named arguments now
		forEachClassField(function(fd:SfClassField) {
			switch (fd.kind) {
				case FMethod(_): {};
				default: return;
			}
			if (fd.expr == null) return;
			proc(fd.expr, fd.args, fd.needsThisArg());
		});
	}
}
private typedef SfGmlArgsData = {
	arg:SfArgument,
	v:SfVar,
	found:Int,
	index:Int,
	first:SfExpr,
	from:SfExpr,
}
