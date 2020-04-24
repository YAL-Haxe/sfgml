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
	public function pre():Void {
		var tArray = sfGenerator.typeArray;
		var Array_length = tArray.realMap["length"];
		var tArrayImpl = sfGenerator.findRealClass("gml.internal.ArrayImpl");
		var fieldMap = tArrayImpl != null ? tArrayImpl.realMap : new Map();
		if (tArrayImpl != null) {
			for (fd in tArrayImpl.fieldList) fd.isHidden = true;
		}
		//
		var modern = sfConfig.modern;
		var array_length = "array_length";
		if (!modern) array_length += "_1d";
		//
		inline function isArrayField(fd:SfClassField):Bool {
			return fd.parentClass == tArray;
		}
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
		forEachExpr(function(x:SfExpr, st, it) {
			switch (x.def) {
				case SfNew(c, _, []) if (c == tArray): {
					x.def = SfArrayDecl([]);
				};
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
				case SfInstField(inst, fd) if (fd == Array_length): {
					x.def = SfCall(x.mod(SfIdent(array_length)), [inst]);
				};
				case SfCall(_.def => SfInstField(arr, fd), args) if (isArrayField(fd)): {
					var fdi = fieldMap[fd.realName];
					if (fdi != null) {
						fieldMap.remove(fd.realName);
						fdi.isHidden = false;
						args.unshift(arr);
						x.def = SfCall(x.mod(SfStaticField(tArrayImpl, fdi)), args);
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