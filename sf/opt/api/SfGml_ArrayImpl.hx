package sf.opt.api;

import haxe.ds.Map;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;

/**
 * https://github.com/HaxeFoundation/haxe/issues/9346
 * @author YellowAfterlife
 */
class SfGml_ArrayImpl extends SfOptImpl {
	private var isPost:Bool;
	public function new(isPost:Bool) {
		super();
		this.isPost = isPost;
		ignoreHidden = true;
	}
	static function exprIsArray(x:SfExpr):Bool {
		return switch (x.getTypeNz()) {
			case TInst(_.get() => {module:"Array", name:"Array"}, _): true;
			default: false;
		}
	}
	public function pre():Void {
		var tArray = sfGenerator.typeArray;
		var Array_length = tArray.realMap["length"];
		var tArrayImpl = sfGenerator.findRealClass("gml.internal.ArrayImpl");
		var fieldMap = tArrayImpl != null ? tArrayImpl.realMap : new Map();
		if (tArrayImpl != null) {
			for (fd in tArrayImpl.fieldList) fd.isHidden = true;
		}
		
		//
		tArray.meta.add(":docName", [{
			expr: EConst(CString("array")),
			pos: tArray.baseType.pos
		}], tArray.baseType.pos);
		tArray.exposePath = "array";
		
		//
		var modern = sfConfig.modern;
		var array_length = "array_length";
		if (!modern) array_length += "_1d";
		//
		function getImpl(name:String):SfClassField {
			var fd = fieldMap[name];
			if (fd == null) return null;
			if (fd.isHidden) {
				fd.isHidden = false;
				var pre = name + "_";
				for (fd in tArrayImpl.fieldList) if (fd.isHidden) {
					if (StringTools.startsWith(fd.realName, pre)) {
						fd.isHidden = false;
					}
				}
			}
			return fd;
		}
		//
		var ih = ignoreHidden;
		ignoreHidden = false;
		forEachExpr(function(x:SfExpr, st, it) {
			switch (x.def) {
				case SfNew(c, _, []) if (c == tArray): {
					// new Array() -> []
					x.def = SfArrayDecl([]);
				};
				case SfBinop(OpAssign, _.def => SfInstField(inst, fd), len) if (fd == Array_length): {
					//
					if (modern) {
						x.def = SfCall(x.mod(SfIdent("array_resize")), [inst, len]);
					} else x.error("Array resizing is only supported in 2.3+");
				};
				case SfInstField(inst, fd) if (fd == Array_length): {
					x.def = SfCall(x.mod(SfIdent(array_length)), [inst]);
				};
				default:
			}
			x.iter(st, it);
		});
		ignoreHidden = ih;
		//
		forEachExpr(function(x:SfExpr, st, it) {
			switch (x.def) {
				case SfBinop(OpAssign, _.def => SfInstField(inst, fd), v) if (fd == Array_length): {
					if (modern) {
						x.def = SfCall(x.mod(SfIdent("array_resize")), [inst, v]);
					} else {
						var fdi = getImpl("resize");
						if (fdi != null) {
							var fdx = x.mod(SfStaticField(tArrayImpl, fdi));
							x.def = SfCall(fdx, [inst, v]);
						} else x.error("No ArrayImpl.resize?");
					}
				};
				case SfCall(_.def => SfInstField(arr, fd), args) if (fd.parentClass == tArray): {
					// arr.func(...) -> ArrayImpl.func(arr, ...)
					var fdi = fieldMap[fd.realName];
					if (fdi != null) {
						fdi.isHidden = false;
						args.unshift(arr);
						x.def = SfCall(x.mod(SfStaticField(tArrayImpl, fdi)), args);
					}
				};
				case SfCall(
					_.def => SfDynamicField(_.def => SfCast(arr, null), "slice"), []
				) if (exprIsArray(arr)): {
					// (cast arr).slice() -> arr.copy()
					// [reverts JS-specific optimization]
					var fdi = getImpl("copy");
					if (fdi != null) {
						var fdx = x.mod(SfStaticField(tArrayImpl, fdi));
						x.def = SfCall(fdx, [arr]);
					} else arr.error("No ArrayImpl.copy?");
				};
				case SfCall(
					_.def => SfDynamicField(_.def => SfCast(arr, null), "splice"), [
						ind,
						_.def => SfConst(TInt(0)),
						val,
					]
				) if (exprIsArray(arr)): {
					// (cast arr).splice(ind, 0, val) -> arr.insert(arr, ind, val)
					// [reverts JS-specific optimization]
					if (modern) {
						x.def = SfCall(x.mod(SfIdent("array_insert")), [arr, ind, val]);
					} else {
						var fdi = getImpl("insert");
						if (fdi != null) {
							var fdx = x.mod(SfStaticField(tArrayImpl, fdi));
							x.def = SfCall(fdx, [arr]);
						} else arr.error("No ArrayImpl.insert?");
					}
				};
				default: 
			}
			x.iter(st, it);
		});
	}
	public function post():Void {
		var tArrayImpl = sfGenerator.findRealClass("gml.internal.ArrayImpl");
		if (tArrayImpl == null) return;
		forEachExpr(function(x:SfExpr, st, it) {
			switch (x.def) {
				case SfStaticField(c, f) if (c == tArrayImpl && f.isHidden): {
					f.isHidden = false;
					var pre = f.realName + "_";
					for (fd in tArrayImpl.fieldList) {
						if (StringTools.startsWith(fd.realName, pre)) fd.isHidden = false;
					}
				};
				default:
			}
			x.iter(st, it);
		});
	}
	override public function apply():Void {
		if (isPost) post(); else pre();
	}
}