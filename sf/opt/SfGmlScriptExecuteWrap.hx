package sf.opt;
import haxe.ds.Map;
import haxe.ds.ObjectMap;
import sf.type.expr.SfExpr;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlScriptExecuteWrap extends SfOptImpl {
	public static var map:Map<Int, SfClassField> = new Map();
	// sfgml_script_execute_wrap
	override public function apply() {
		var boot = SfCore.sfGenerator.typeBoot;
		#if (sfgml_script_execute_wrap)
		var found = new ObjectMap();
		forEachExpr(function(e:SfExpr, w:SfExprList, fn:SfExprIter) {
			e.iter(w, fn);
			do switch (e.def) {
				case SfStaticField(c, f): {
					if (!f.isCallable || f.isVar) continue;
					if (w.length > 0) switch (w[0].def) {
						case SfCall(x, _) if (x == e): continue;
						default:
					}
					if (found.exists(f)) continue;
					found.set(f, true);
					var argc = f.args.length;
					var cf = map[argc];
					if (cf == null) {
						var tf = boot.staticMap["script_execute"];
						var te:SfExpr = tf.expr;
						cf = new SfClassField(boot, tf.classField, false);
						cf.name = "script_execute_" + argc;
						map.set(argc, cf);
						//
						var args = [te.mod(SfDynamic("argument0", []))];
						for (i in 1 ... argc + 1) {
							args.push(te.mod(SfDynamic("argument" + i, [])));
						}
						//
						cf.expr = te.mod(SfSwitch(
							te.mod(SfDynamic("argument0", [])),
							[],
							true,
							te.mod(SfCall(te.mod(SfDynamic("script_execute", [])), args))
						));
						boot.addField(cf);
					}
					switch (cf.expr.def) {
						case SfSwitch(_, cc, _, _): {
							var args = [];
							for (i in 1 ... argc + 1) {
								args.push(e.mod(SfDynamic("argument" + i, [])));
							}
							//
							cc.push({
								values: [e.clone()],
								expr: e.mod(SfCall(e.clone(), args))
							});
						};
						default:
					}
				};
				default:
			} while (false);
		}, []);
		boot.staticMap["script_execute"].isHidden = true;
		#end
	}
}
