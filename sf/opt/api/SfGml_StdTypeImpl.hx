package sf.opt.api;

import haxe.ds.Map;
import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;

/**
 * Mapping SfInstanceOf(expr, Type) to context-specific GML functions.
 * @author YellowAfterlife
 */
class SfGml_StdTypeImpl extends SfOptImpl {
	
	public static inline var realPath:String = "gml.internal.StdTypeImpl";
	
	/**
	 * Whether StdTypeImpl.is occurs in generated code.
	 * On non-modern this is used as condition to print the type-check grid.
	 */
	public static var isUsed:Bool;
	
	private var isPost:Bool;
	
	public function new(isPost:Bool) {
		super();
		this.isPost = isPost;
	}
	
	static inline function getFieldSoft(c:SfClass, name:String):SfClassField {
		return c != null ? c.realMap[name] : null;
	}
	
	public function applyPre(_StdTypeImpl:SfClass) {
		var modern = sfConfig.modern;
		//
		var _Std = sfGenerator.findRealClass("Std");
		var _isNumber = getFieldSoft(_StdTypeImpl, "isNumber");
		var _isNumber_usedBy = null;
		var _isIntNumber = getFieldSoft(_StdTypeImpl, "isIntNumber");
		var _isIntNumber_usedBy = null;
		var _isGeneric = getFieldSoft(_StdTypeImpl, "is");
		var _isGeneric_usedBy = null;
		#if !sfgml_legacy_meta
		var _MetaType = sfGenerator.findRealClass("gml.MetaType");
		var _MetaType_has = getFieldSoft(_MetaType, "has");
		var _MetaType_has_usedBy:SfExpr = null;
		#end
		
		//
		forEachExpr(function(e:SfExpr, st, it) {
			if (_Std != null && currentClass == _Std) return;
			e.iter(st, it);
			switch (e.def) {
				case SfInstanceOf(x, tx): {
					var sft:SfType = switch (tx.unpack().def) {
						case SfTypeExpr(t): t;
						default: return;
					};
					//
					inline function isfn(s:String) {
						e.def = SfCall(e.mod(SfIdent(s)), [x]);
					}
					inline function isfd(fd:SfClassField):Void {
						e.def = SfCall(e.mod(SfStaticField(_StdTypeImpl, fd)), [x]);
					}
					//
					switch (sft.realPath) {
						case "String": isfn("is_string");
						case "Float": {
							if (modern) {
								isfn("is_numeric");
							} else {
								isfd(_isNumber);
								_isNumber_usedBy = e;
							}
						};
						case "Int": {
							isfd(_isIntNumber);
							_isIntNumber_usedBy = e;
						};
						case "Bool": isfn("is_bool");
						case "Array": isfn("is_array");
						case "haxe.Int64": isfn("is_int64");
						case "Dynamic": {
							var zx = x.mod(SfConst(TNull));
							var ex = x.mod(SfBinop(OpNotEq, x, zx));
							e.def = SfParenthesis(ex);
						};
						default: {
							if (_isGeneric != null) {
								var fx = e.mod(SfStaticField(_StdTypeImpl, _isGeneric));
								e.def = SfCall(fx, [x, tx]);
								_isGeneric_usedBy = e;
							} else {
								e.error("StdTypeImpl.is was not compiled."
									+ " Try referencing Std.is somewhere.");
							}
						};
					}
				};
				case SfStaticField(c, f) if (c != null && c == _StdTypeImpl
					&& f != null && f == _isGeneric
					&& (_Std == null || currentClass != _Std)
				): {
					_isGeneric_usedBy = e;
				};
				#if !sfgml_legacy_meta
				case SfStaticField(c, f) if (c != null && c == _MetaType
					&& f != null && f == _MetaType_has
					&& (_StdTypeImpl == null || currentClass != _StdTypeImpl)
				): {
					_MetaType_has_usedBy = e;
				};
				#end
				default:
			} // switch, can return
		});
		isUsed = _isGeneric_usedBy != null;
		
		// cleanup unused fields:
		inline function checkCleanField(fd:SfClassField, usedBy:SfExpr):Void {
			if (fd == null) return;
			if (usedBy != null) {
				//usedBy.warning(fd.getPathAuto() + " is used here.");
				return;
			}
			fd.isHidden = true;
		}
		checkCleanField(_isGeneric, _isGeneric_usedBy);
		checkCleanField(_isNumber, _isNumber_usedBy);
		checkCleanField(_isIntNumber, _isIntNumber_usedBy);
		#if !sfgml_legacy_meta
		if (_MetaType_has_usedBy == null) _MetaType_has_usedBy = _isGeneric_usedBy;
		checkCleanField(_MetaType_has, _MetaType_has_usedBy);
		#end
	}
	
	/**
	 * Strip out cases with unreferenced types in StdTypeImpl.is
	 */
	public function applyPost(_StdTypeImpl:SfClass) {
		var _isGeneric = getFieldSoft(_StdTypeImpl, "is");
		if (_isGeneric != null && !_isGeneric.isHidden) {
			var igx = _isGeneric.expr;
			var cc:Array<SfExprCase> = null;
			function check(e:SfExpr, st, it) {
				switch (e.def) {
					case SfSwitch(expr, cases, hasDefault, edefault): {
						cc = cases;
						return true;
					};
					default: return e.matchIter(st, check);
				}
			}
			check(igx, null, check);
			if (cc != null) {
				var i = cc.length;
				while (--i >= 0) {
					switch (cc[i].values[0].def) {
						case SfTypeExpr(t) if (!t.hasTypeExpr): {
							//trace(t + " is unused");
							cc.splice(i, 1);
						}
						default:
					}
				}
			}
		}
	}
	
	override public function apply():Void {
		ignoreHidden = true;
		var _StdTypeImpl = sfGenerator.findRealClass(realPath);
		if (isPost) {
			applyPost(_StdTypeImpl);
		} else {
			applyPre(_StdTypeImpl);
		}
	}
}