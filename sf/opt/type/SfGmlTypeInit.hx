package sf.opt.type;
import sf.SfCore.*;
import sf.type.SfBuffer;
import sf.type.*;
import sf.type.expr.*;
/**
 * ...
 * @author ...
 */
class SfGmlTypeInit {
	public static function printMeta(init:SfBuffer):Void {
		var mtModule = SfGmlType.mtModule;
		var foundMTs = false;
		for (t in sfGenerator.typeList) {
			if (t.module == mtModule) continue;
			if (!t.hasMetaType()) continue;
			foundMTs = true;
			break;
		}
		if (!foundMTs) {
			// if there are no actual meta-types at all, hide gml.MetaType.*:
			for (t in sfGenerator.typeList) {
				if (t.module != mtModule) continue;
				t.isHidden = true;
			}
			return;
		}
		//
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var stdPack = sfConfig.stdPack;
		var stdPre = stdPack != null ? stdPack + "_" : "";
		//
		if (sfConfig.hintFolds) printf(init, "//{ metatype\n");
		
		#if !sfgml_legacy_meta
		// we'll need markerValue defined before anything else
		// since meta type constructors will reference it:
		var qMetaType = sfGenerator.findRealClass("gml.MetaType");
		var qMetaMarker = qMetaType.realMap["markerValue"];
		var qMetaMarkerText:String = null;
		if (qMetaMarker != null) {
			qMetaMarkerText = sprintf("%(field_auto)", qMetaMarker);
			//
			printf(init, "globalvar %s;`%s`=`", qMetaMarkerText, qMetaMarkerText);
			if (!sfConfig.hasArrayCreate) {
				printf(init, "0;`%s[0]`=`undefined", qMetaMarkerText);
			} else if (!hasArrayDecl) {
				printf(init, "array_create(0)");
			} else printf(init, "[]");
			printf(init, ";\n");
		}
		#end
		//
		var qMetaClass = sfGenerator.findRealClass("gml.MetaClass");
		var qMetaClass_super = qMetaClass != null ? qMetaClass.realMap["superClass"] : null;
		
		//
		var typeBoot = sfGenerator.typeBoot;
		var modern = sfConfig.modern;
		for (t in sfGenerator.typeList) {
			if (!t.hasMetaType()) continue;
			var e:SfEnum = Std.is(t, SfEnum) ? cast t : null;
			var c:SfClass = Std.is(t, SfClass) ? cast t : null;
			//
			printf(init, "globalvar mt_%(type_auto);`mt_%(type_auto)`=`", t, t);
			if (modern) {
				printf(init, "new %s%s", stdPre, e != null ? "haxe_enum" : "haxe_class");
			} else {
				printf(init, "%s%s_create", stdPre, e != null ? "haxe_enum" : "haxe_class");
			}
			printf(init, '(%d,`"%(type_auto)"', t.index, t);
			if (e != null) do {
				if (!e.ctrNames) break;
				if (hasArrayDecl) {
					printf(init, ",`[");
				} else {
					printf(init, ",`%(field_auto)(", typeBoot.realMap["decl"]);
				}
				var sep = false;
				for (c in e.ctrList) {
					if (sep) init.addComma(); else sep = true;
					printf(init, '"%s"', c.name);
				}
				if (hasArrayDecl) {
					printf(init, "]");
				} else {
					printf(init, ")");
				}
			} while (false);
			else if (c != null) {
				var c:SfClass = cast t;
				if (c.constructor != null && c.isStruct) printf(init, ",`%(type_auto)", t);
			}
			printf(init, ");\n");
			//
			if (modern && c != null && c.superClass != null && c.module != SfGmlType.mtModule) {
				if (qMetaClass_super != null) {
					printf(init, "mt_%(type_auto).%s`=`mt_%(type_auto);\n",
						c, qMetaClass_super.name, c.superClass);
				} else {
					haxe.macro.Context.warning(
						"Can't print superClass - field missing",
						c.classType.pos);
				}
			}
		}
		
		//
		
		//
		if (sfConfig.hintFolds) printf(init, "//}\n");
	}
	public static function printProto(init:SfBuffer) {
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var hint = sfConfig.hint;
		var stdPack = sfConfig.stdPack;
		//
		var fns = sfConfig.fieldNames;
		var next = sfConfig.next;
		
		// generate prototypes for linear classes:
		var pbuf = new SfBuffer();
		for (c in sfGenerator.classList) {
			if (c.isHidden || c.constructor == null) continue;
			if (c.nativeGen && !fns) continue;
			if (c.isStruct) continue;
			//
			printf(pbuf, "globalvar mq_%(type_auto);`mq_%(type_auto)`=`", c, c);
			if (!hasArrayDecl) {
				if (stdPack != null) printf(pbuf, "%s_", stdPack);
				pbuf.addString("haxe_type_proto(");
			} else pbuf.addChar("[".code);
			if (c.indexes > 0) {
				var proto:Array<String> = [];
				var cng = c.nativeGen;
				if (!cng) {
					for (i in 0 ... c.indexes) proto.push("undefined");
				} else for (i in 0 ... c.indexes) proto.push("0");
				
				// collect the field values, preferring closer in inheritance chain:
				var q = c;
				do {
					for (f in q.instList) if (f.index >= 0) {
						var fi = f.index;
						if (fns) proto[fi - 1] = '"' + f.name + '"';
						if (!cng) switch (f.type) {
							case TAbstract(_.get() => { name: "Int"|"Float"|"Int64" }, _): {
								proto[fi] = "0";
							};
							default:
						}
						if (hint) proto[fi] = '/* $fi:${f.name} */' + proto[fi];
					}
					q = q.superClass;
				} while (q != null);
				
				pbuf.addString(proto[0]);
				for (i in 1 ... c.indexes) {
					printf(pbuf, ",`%s", proto[i]);
				}
			}
			printf(pbuf, "%c;\n", hasArrayDecl ? "]".code : ")".code);
		}
		if (pbuf.length > 0) {
			if (sfConfig.hintFolds) printf(init, "//{ prototypes\n");
			init.addBuffer(pbuf);
			if (sfConfig.hintFolds) printf(init, "//}\n");
		}
	}
}