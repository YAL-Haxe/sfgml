package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
import sf.SfCore.*;
using sf.type.SfExprTools;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * Handles GML-specific trailing arguments.
 * @author YellowAfterlife
 */
class SfGmlRest extends SfOptImpl {
	override public function apply() {
		var sfRest:SfClass = sfGenerator.typeFind("SfRest:SfRest", SfClass);
		if (sfRest == null) return;
		forEachExpr(function(e:SfExpr, w, f) {
			if (currentField == null) return;
			var args = currentField.args;
			if (args == null) return;
			var argc = args.length;
			if (argc > 0) switch (args[argc - 1].v.type) {
				case TAbstract(_.get() => t, _) if (t.name == "SfRest"): {
					currentField.restOffset = argc - (currentField.isInst ? 0 : 1);
				};
				default:
			}
		});
		sfRest.isHidden = true;
		var sfRest_create = sfRest.staticMap["create"];
		var sfRest_get = sfRest.staticMap["get"];
		function iter(e:SfExpr, w:Array<SfExpr>, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfCall(_.def => SfStaticField(c, f), par) if (c == sfRest): {
					function offset(q:SfExpr, argc:Bool):SfExpr {
						var i = currentField.restOffset;
						if (argc) i *= -1;
						if (i != 0) {
							var d = q.getData();
							switch (q.def) {
								case SfConst(TInt(k)): q = e.mod(SfConst(TInt(k + i)));
								default: {
									q = e.mod(SfBinop(i > 0 ? OpAdd : OpSub,
										q, e.mod(SfConst(TInt(i > 0 ? i : -i)))));
									if (argc && !e.isWrapped(w)) q = e.mod(SfParenthesis(q));
								};
							}
							return q;
						} else return q;
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
							e.def = offset(e.mod(SfDynamic("argument_count", [])), true).def;
						};
						case "get": {
							e.def = SfDynamic("argument[{0}]", [offset(par[1], false)]);
						};
						case "set": {
							e.def = SfDynamic("argument[{0}] = {1}", [
								offset(par[1], false), par[2]
							]);
						};
					}
				};
				default:
			}
		}
		forEachExpr(function(e, w, f) {
			if (currentField != null) iter(e, w, iter);
		}, []);
		//trace(sfRest.impl.staticMap.keys());
		/*if (sfRest == null) return;
		forEachExpr(function(e:SfExpr, w, f) {
			if (currentField != null && currentField.name == "map_create") {
				var args = currentField.args;
				var argc = args.length;
				if (argc > 0) switch (args[argc - 1].v.type) {
					case TAbstract(_.get() => t, _) if (t.name == "SfRest"): {
						currentField.restOffset = argc - 1;
					};
					default:
				}
			}
		});
		var sfRest_create = sfRest.staticMap["create"];
		var sfRest_get = sfRest.staticMap["get"];
		var sfRest_set = sfRest.staticMap["set"];
		forEachExpr(function(e:SfExpr, w:Array<SfExpr>, f) {
			e.iter(w, f);
			switch (e) {
				case SfCall(SfStaticField(c, f), par) if (c == sfRest): {
					if (f == sfRest_create) {
						trace(par[0].dump());
						var rest = switch (par[0]) {
							case SfArrayDecl(w): w;
							default: e.error("" + currentClass.name);
						}
						var q = w[0], p = e;
						switch (q) { // @:implicitCast
							case SfMeta(_, _): q = w[1]; p = w[0];
							default:
						}
						switch (q) {
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
					} else if (f == sfRest_get) {
						
					} else if (f == sfRest_set) {
						
					}
				};
				default:
			}
		}, []);*/
	}
}
