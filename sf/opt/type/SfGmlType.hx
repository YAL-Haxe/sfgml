package sf.opt.type;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.opt.legacy.*;
import sf.SfCore.*;
import haxe.macro.Type;
import haxe.macro.Type.TConstant.*;
import haxe.macro.Type.Type.*;
import SfTools.*;

/**
 * In pre-2.3, GML arrays were always 2d, so the second row could be used to store metadata.
 * This behaviour is enabled via -D sfgml_legacy_meta.
 * 
 * In 2.3, sfgml will store metadata in the first array index for linear objects,
 * or in __class__/__enum__ for struct-based ones.
 * 
 * Metadata is represented by gml.MetaType, which is instantiated for each non-extern type
 * and then is used when that type is referenced.
 * @author YellowAfterlife
 */
class SfGmlType extends SfOptImpl {
	public static var usesType:Bool = false;
	public static var usesClass:Bool = false;
	public static var usesProto:Bool = false;
	public static var usesEnum:Bool = false;
	public static inline var mtModule:String = "gml.MetaType";
	
	function procTypeRemap() {
		var mtClass = sfGenerator.classMap.safeGet(mtModule, "class");
		var stdClass = sfGenerator.typeClass;
		forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfTypeExpr(t) if (t == stdClass): e.def = SfTypeExpr(mtClass);
				default: 
			}
		});
		var stdClassImpl = sfGenerator.typeMap.get("Class", "Class_Impl_");
		if (stdClassImpl != null) forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfTypeExpr(t) if (t == stdClassImpl): e.def = SfTypeExpr(mtClass);
				default: 
			}
		});
	}
	
	function procMetaTypeUses() {
		var sfg = sfGenerator;
		var sfTypes = sfg.typeList;
		var sfClasses:Array<SfClass> = sfg.classList;
		var sfEnums = sfg.enumList;
		// mark types referenced in code as used:
		forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfTypeExpr(t): t.isUsed = true;
				case SfEnumField(t, _): t.isUsed = true;
				default:
			}
		});
		// mark classes with constructors as used:
		for (c in sfClasses) if (!c.isHidden) {
			if (c.constructor != null) c.isUsed = true;
		}
		// mark :keep'ed enums as used:
		for (e in sfEnums) if (!e.isUsed) {
			if (e.hasMeta(":keep") && !e.isFake) e.isUsed = true;
		}
		// hide unused enums:
		for (e in sfEnums) if (!e.isUsed) {
			if (!e.isHidden && !e.nativeGen) e.isHidden = true;
		}
		//
		var i:Int, n:Int;
		//
		i = -1; n = sfTypes.length;
		while (++i < n) {
			var t = sfTypes[i];
			if (t.isUsed && !t.nativeGen && !t.isExtern && t.module != mtModule) break;
		}
		//
		var fns = sfConfig.fieldNames;
		usesProto = false;
		for (c in sfClasses) {
			if (c.isHidden || c.constructor == null) continue;
			if (!fns && c.nativeGen) continue;
			if (c.module == "gml.MetaType") continue;
			usesProto = true;
			break;
		}
		//
		if (usesProto) {
			usesType = true;
			//
			usesClass = false;
			for (c in sfClasses) {
				if (c.isUsed && !c.nativeGen && c.module != mtModule) {
					usesClass = true;
					break;
				}
			}
			//
			usesEnum = false;
			for (e in sfEnums) {
				if (e.isUsed && !e.nativeGen && !e.isExtern && !e.isFake) {
					usesEnum = true;
					break;
				}
			}
		}
		//
		if (!usesClass) sfGenerator.typeMap.get(mtModule, "class").isHidden = true;
		if (!usesEnum) sfGenerator.typeMap.get(mtModule, "enum").isHidden = true;
	}
	
	function procMetaTypeStatics() {
		var mtClass = sfGenerator.classMap.get(mtModule, "type");
		if (sfConfig.hasArrayDecl || !usesProto) {
			mtClass.staticMap.get("proto").isHidden = true;
		}
		var mtGet = mtClass.fieldMap.get("get");
		var mtGetUsedBy = null;
		var mtSet = mtClass.fieldMap.get("set");
		var mtSetUsedBy = null;
		#if sfgml_legacy_meta
		var mtCopySet = mtClass.fieldMap.get("copyset");
		var canCopySet = sfConfig.copyset;
		forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfCall(_.def => SfStaticField(c, f), m) if (c == mtClass): {
					var x = m[0];
					if (f == mtGet) {
						if (SfGmlArrayAccess.needsWrapping(x)) {
							mtGetUsedBy = e;
						} else e.def = SfDynamic("{0}[1,0]", [x]);
					}
					else if (f == mtSet) {
						if (SfGmlArrayAccess.needsWrapping(x)) {
							mtSetUsedBy = e;
						} else e.def = SfBinop(OpAssign, e.mod(SfDynamic("{0}[@1,0]", [x])), m[1]);
					}
					else if (f == mtCopySet) {
						if (canCopySet) {
							if (SfGmlArrayAccess.needsWrapping(x)) {
								e.error("Can't expand MetaType.copyset here.");
							} else {
								e.def = SfBinop(OpAssign, e.mod(SfDynamic("{0}[1,0]", [x])), m[1]);
							}
						} else {
							e.error("copyset is bugged at this time.");
							//mtCopySet.isHidden = false;
						}
					}
				}
				default:
			}
		});
		#else
		forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfCall(_.def => SfStaticField(c, f), m) if (c == mtClass): {
					if (f == mtGet) {
						mtGetUsedBy = e;
					} else if (f == mtSet) {
						mtSetUsedBy = e;
					}
				};
				default:
			};
		});
		#end
		if (mtGetUsedBy == null) mtClass.removeField(mtGet);
		if (mtSetUsedBy == null) mtClass.removeField(mtSet);
	}
	
	/**
	 * Linear constructors are structured like
	 * function create() { var this = *; ...; return this; }
	 * so we want `return` to become `return this`
	 */
	function procConstructorReturns() {
		function iter(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfReturn(false, null): e.def = SfReturn(true, e.mod(SfConst(TThis)));
				default:
			}
		}
		forEachClassField(function(f:SfClassField) {
			if (f.isStructField) return;
			if (f == f.parentClass.constructor && f.expr != null) {
				iter(f.expr, null, iter);
			}
		});
	}
	
	function procEnumConstructor() {
		var rType:SfClass = cast sfGenerator.realMap.get("Type");
		if (rType != null) {
			var rEnumConstructor = rType.realMap.get("enumConstructor");
			if (rEnumConstructor != null) forEachExpr(function(e:SfExpr, w, f) {
				switch (e.def) {
					case SfCall(_.def => SfStaticField(_, f), [x]) if (f == rEnumConstructor): {
						switch (x.getType()) {
							case TEnum(_.get() => et, _): {
								var e = sfGenerator.enumMap.baseGet(et);
								e.ctrNames = true;
							};
							default: { // it could be ANY enum
								for (e in sfGenerator.enumList) {
									if (e.isHidden) continue;
									e.ctrNames = true;
								}
							};
						}
					};
					default:
				}
				e.iter(w, f);
			});
		}
	}
	
	function procTypeMap(isEnum:Bool) {
		var rMap:SfClassField = sfGenerator.findRealClassField("js.Boot", 
			isEnum ? "resolveEnumMap" : "resolveClassMap");
		if (rMap == null) return;
		var b = rMap.expr;
		var init:Array<SfExpr> = [];
		var v:SfVar = new SfVar("m", rMap.type);
		var lv = b.mod(SfLocal(v));
		var mapNew = b.mod(SfCall(b.mod(SfIdent("ds_map_create")), []));
		init.push(b.mod(SfVarDecl(v, true, mapNew)));
		var mapSet:SfExpr = b.mod(SfIdent("ds_map_set"));
		//
		function addType(c:SfType):Void {
			if (!c.hasMetaType()) return;
			var cb = new SfBuffer();
			cb.addTypePath(c);
			init.push(b.mod(SfCall(mapSet.clone(), [
				lv.clone(),
				b.mod(SfConst(TString(cb.toString()))),
				b.mod(SfTypeExpr(c)),
			])));
		}
		if (isEnum) {
			for (c in sfGenerator.enumList) addType(c);
		} else {
			for (c in sfGenerator.classList) addType(c);
		}
		init.push(lv.clone());
		rMap.expr = b.mod(SfBlock(init));
	}
	
	override public function apply() {
		procTypeRemap();
		procMetaTypeUses();
		procMetaTypeStatics();
		procConstructorReturns();
		procEnumConstructor();
		procTypeMap(false);
		procTypeMap(true);
	}
	
}
