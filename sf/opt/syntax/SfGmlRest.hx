package sf.opt.syntax;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * Handles GML-specific trailing arguments.
 * @author YellowAfterlife
 */
class SfGmlRest extends SfOptImpl {
	public static function getRestType(t:Type):Type {
		switch (t) {
			case TAbstract(_.get() => { name: "SfRest" }, [q]): {
				return q;
			};
			case TAbstract(_.get() => { name: "Null" }, [
				TAbstract(_.get() => { name: "SfRest" }, [q])
			]): {
				return q;
			};
			case TType(_.get() => td, _): {
				return getRestType(td.type);
			};
			default: return null;
		}
	}
	override public function apply() {
		var sfRest:SfClass = sfGenerator.typeFind("SfRest:SfRest", SfClass);
		if (sfRest == null) return;
		forEachExpr(function(e:SfExpr, w, f) {
			if (currentField == null) return;
			var args = currentField.args;
			if (args == null) return;
			var argc = args.length;
			if (argc > 0 && getRestType(args[argc - 1].v.type) != null) {
				currentField.restOffset = argc - (currentField.isInst && !currentField.dotAccess ? 0 : 1);
			}
		});
		sfRest.isHidden = true;
		var sfRest_create = sfRest.staticMap["create"];
		var sfRest_get = sfRest.staticMap["get"];
		var restOffset:Int = -1;
		function iter(e:SfExpr, w:Array<SfExpr>, f) {
			switch (e.def) {
				case SfFunction(ef):
					var _restOffset = restOffset;
					var args = ef.args;
					var argc = args.length;
					if (argc > 0 && getRestType(args[argc - 1].v.type) != null) {
						restOffset = argc - 1;
					} else restOffset = 0;
					e.iter(w, f);
					restOffset = _restOffset;
				default:
					e.iter(w, f);
			}
			switch (e.def) {
				case SfCall(_.def => SfStaticField(c, f), par) if (c == sfRest): {
					function offset(argc:Bool):Void {
						var i = currentField.restOffset;
						if (argc) i *= -1;
						e.adjustByInt(w, i);
					}
					switch (f.name) {
						case "create": {
							var rest = switch (par[0].def) {
								case SfArrayDecl(w): w;
								case SfCall(_.def => SfStaticField(c, f), w)
								if (c.module == "Array" && f.name == "decl"): w;
								default: e.error("SfRest can only be cast from an array literal.");
							}
							var q = w[0], p = e;
							switch (q.def) { // unwrap @:implicitCast
								case SfMeta(_, _): q = w[1]; p = w[0];
								default:
							}
							switch (q.def) {
								case SfCall(x, args): {
									var argc = args.length;
									if (args[argc - 1] != p) {
										e.error("SfRest may only be the last argument.");
									}
									args.splice(argc - 1, 1);
									for (q in rest) args.push(q);
								};
								default: e.error("SfRest may not be constructed standalone.");
							}
						}; // create
						case "get_length": {
							inline function isCmp(o:Binop):Bool {
								return switch (o) {
									case OpEq | OpNotEq | OpGt | OpGte | OpLt | OpLte: true;
									default: false;
								}
							}
							e.def = SfDynamic("argument_count", []);
							e.adjustByInt(w, -restOffset);
						};
						case "get": {
							par[1].adjustByInt(null, restOffset);
							e.def = SfDynamic("argument[{0}]", [par[1]]);
						};
						case "set": {
							par[1].adjustByInt(null, restOffset);
							e.def = SfDynamic("argument[{0}] = {1}", [par[1], par[2]]);
						};
					}
				};
				default:
			}
		}
		forEachExpr(function(e, w, f) {
			if (currentField == null) return;
			restOffset = currentField.restOffset;
			iter(e, w, iter);
		}, []); 
	}
}
