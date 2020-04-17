package sf.opt;
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
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var stdPack = sfConfig.stdPack;
		//
		if (sfConfig.hintFolds) printf(init, "//{ metatype\n");
		var mtModule = SfGmlType.mtModule;
		//
		#if !sfgml_legacy_meta
		var qMetaType:SfClass = cast sfGenerator.realMap["gml.MetaType"];
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
		var typeBoot = sfGenerator.typeBoot;
		var modern = sfConfig.modern;
		for (t in sfGenerator.typeList) {
			if (t.isHidden || t.nativeGen) continue;
			if (!t.isUsed) continue;
			var e:SfEnum = null;
			if (Std.is(t, SfEnum)) {
				e = cast t;
				if (e.isFake) continue;
			} else if (Std.is(t, SfClass)) {
				var c:SfClass = cast t;
				if (c.constructor == null && c.instList.length == 0) continue;
			} else continue;
			//
			printf(init, "globalvar mt_%(type_auto);`mt_%(type_auto)`=`", t, t);
			if (stdPack != null) printf(init, "%s_", stdPack);
			if (modern) {
				printf(init, "new %s", e != null ? "haxe_enum" : "haxe_class");
			} else {
				printf(init, "%s_create", e != null ? "haxe_enum" : "haxe_class");
			}
			printf(init, '(%d,`"%(type_auto)"', t.index, t);
			if (Std.is(t, SfEnum)) {
				var e:SfEnum = cast t;
				if (e.ctrNames) {
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
				}
			}
			printf(init, ");\n");
		}
		//
		if (sfConfig.hintFolds) printf(init, "//}\n");
	}
	public static function printProto(init:SfBuffer) {
		var hasArrayDecl = sfConfig.hasArrayDecl;
		var hint = sfConfig.hint;
		var stdPack = sfConfig.stdPack;
		//
		if (sfConfig.hintFolds) printf(init, "//{ prototypes\n");
		var fns = sfConfig.fieldNames;
		var next = sfConfig.next;
		
		for (c in sfGenerator.classList) {
			if (c.isHidden || c.constructor == null) continue;
			if (c.nativeGen && !fns) continue;
			if (c.isStruct) continue;
			//
			printf(init, "globalvar mq_%(type_auto);`mq_%(type_auto)`=`", c, c);
			if (!hasArrayDecl) {
				if (stdPack != null) printf(init, "%s_", stdPack);
				init.addString("haxe_type_proto(");
			} else init.addChar("[".code);
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
				
				init.addString(proto[0]);
				for (i in 1 ... c.indexes) {
					printf(init, ",`%s", proto[i]);
				}
			}
			printf(init, "%c;\n", hasArrayDecl ? "]".code : ")".code);
		}
		if (sfConfig.hintFolds) printf(init, "//}\n");
	}
}