package sf.opt;

import sf.opt.SfOptImpl;
import sf.type.expr.SfExprDef.*;
import sf.type.*;
import sf.type.expr.*;
using sf.type.expr.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Type;
import haxe.macro.Type.TConstant.*;
import haxe.macro.Type.Type.*;
import SfTools.*;

/**
 * GML arrays are actually always 2d, so the second row is used to store a "metatype" reference.
 * Metatype (gml.MetaType) in turn stores a reference to parent type and any additional data.
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
			if (t.isUsed && !t.nativeGen && !t.isExtern && t.module != "gml.MetaType") break;
		}
		//
		var fns = sfConfig.fieldNames;
		i = -1; n = sfClasses.length;
		while (++i < n) {
			var c = sfClasses[i];
			if (c.isHidden || c.constructor == null) continue;
			if (!fns && c.nativeGen) continue;
			if (c.module == "gml.MetaType") continue;
			break;
		};
		usesProto = i < n;
		//
		if (i < n) {
			usesType = true;
			//
			i = 0; n = sfClasses.length;
			while (i < n) {
				var c = sfClasses[i];
				if (c.isUsed && !c.nativeGen && c.module != "gml.MetaType") break;
				i += 1;
			}
			usesClass = i < n;
			//
			i = 0; n = sfEnums.length;
			while (i < n) {
				var e = sfEnums[i];
				if (e.isUsed && !e.nativeGen && !e.isExtern && !e.isFake) break;
				i += 1;
			}
			usesEnum = i < n;
		}
		//
		if (!usesType) sfGenerator.typeMap.get(mtModule, "class").isHidden = true;
		if (!usesEnum) sfGenerator.typeMap.get(mtModule, "enum").isHidden = true;
	}
	
	function procMetaTypeStatics() {
		var mtClass = sfGenerator.classMap.get(mtModule, "type");
		if (sfConfig.hasArrayDecl || !usesProto) {
			mtClass.staticMap.get("proto").isHidden = true;
		}
		#if sfgml_legacy_meta
		var mtGet = mtClass.fieldMap.get("get");
		var mtGetUsed = false;
		var mtSet = mtClass.fieldMap.get("set");
		var mtSetUsed = false;
		var mtCopySet = mtClass.fieldMap.get("copyset");
		var canCopySet = sfConfig.copyset;
		forEachExpr(function(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfCall(_.def => SfStaticField(c, f), m) if (c == mtClass): {
					var x = m[0];
					if (f == mtGet) {
						if (SfGmlArrayAccess.needsWrapping(x)) {
							mtGetUsed = true;
						} else e.def = SfDynamic("{0}[1,0]", [x]);
					}
					else if (f == mtSet) {
						if (SfGmlArrayAccess.needsWrapping(x)) {
							mtSetUsed = true;
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
		if (!mtGetUsed) mtClass.removeField(mtGet);
		if (!mtSetUsed) mtClass.removeField(mtSet);
		#end
	}
	
	function procConstructorReturns() {
		function iter(e:SfExpr, w, f) {
			e.iter(w, f);
			switch (e.def) {
				case SfReturn(false, null): e.def = SfReturn(true, e.mod(SfConst(TThis)));
				default:
			}
		}
		forEachExpr(function(e:SfExpr, w, f) {
			if (currentClass != null && currentField == currentClass.constructor) {
				iter(e, w, iter);
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
							default:
						}
					};
					default:
				}
				e.iter(w, f);
			});
		}
	}
	
	override public function apply() {
		procTypeRemap();
		procMetaTypeUses();
		procMetaTypeStatics();
		procConstructorReturns();
		procEnumConstructor();
	}
	
}
