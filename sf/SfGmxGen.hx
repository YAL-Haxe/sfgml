package sf;
import haxe.ds.Map;
import haxe.io.Path;
import haxe.macro.Context;
import sf.type.SfBuffer;
import sf.type.SfClass;
import sf.type.SfClassField;
import sf.type.SfEnum;
import sf.type.*;
import sf.type.expr.*;
import sf.type.SfField;
import sys.FileSystem;
import sys.io.File;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmxGen {
	public static function iter(
		addFunc_:String->String->SfField->Void,
		addMacro_:String->String->String->Void
	) {
		var gd:Bool = sfConfig.gmxDoc;
		var skipFuncs = sfConfig.codePath != null;
		//
		var addMacro_map = new Map<String, SfField>();
		inline function addMacro(name:String, val:String, show:Bool, doc:String, fd:SfField):Void {
			if (addMacro_map.exists(name)) {
				Context.warning('Macro redefinition for $name', fd.typeField.pos);
				Context.warning('First definition of $name was here', addMacro_map[name].typeField.pos);
			} else addMacro_map.set(name, fd);
			addMacro_(name, val, show ? doc : null);
		}
		//
		var addFunc_map = new Map<String, SfField>();
		var addFunc_lq = new Map<String, String>();
		function addFunc(name:String, doc:String, fd:SfField):Void {
			var lq = name.toLowerCase();
			if (addFunc_map.exists(lq)) {
				Context.warning('Function redefinition for $name', fd.typeField.pos);
				var dupName = addFunc_lq[lq];
				var dupPos = addFunc_map[lq].typeField.pos;
				Context.warning('First definition of $dupName was here', dupPos);
				if (dupName != name) {
					Context.warning('This is technically OK (`$dupName`<>`$name`), '
					+ 'but your extension will not compile under YYC on Windows '
					+ 'because file system is case-insensitive and thus they are the same name',
					dupPos);
				}
			} else {
				addFunc_map.set(lq, fd);
				addFunc_lq.set(lq, name);
			}
			addFunc_(name, doc, fd);
		}
		function addClass(sfc:SfClass) {
			if (sfc.isHidden) return;
			var sfcd = sfc.docState;
			//
			for (sff in sfc.staticList) if (!sff.isHidden) switch (sff.kind) {
				case FVar(_, _): {
					var show = sff.checkDocState(sfcd);
					var path = sff.getPathAuto();
					var doc = sff.doc;
					var mcrValue:String;
					switch (sff.kind) {
						case FVar(AccInline | AccCall, AccNo | AccNever): { // inline var v = 4 -> 4
							mcrValue = sff.getGetterMacro();
						};
						default: mcrValue = "g_" + path;
					}; // mcrValue = switch(sff.kind)
					if (mcrValue != null) {
						if (show) {
							var sfb = new SfBuffer();
							printf(sfb, "(%base_type)", sff.type);
							if (doc != null && doc != "") printf(sfb, "%s", doc);
							doc = sfb.toString();
						}
						addMacro(path, mcrValue, show, doc, sff);
					}
				}; // FVar
				case FMethod(_): {
					addFunc(sff.getPathAuto(), sff.getArgDoc(sfcd), sff);
				};
			} // for (field in statics)
			//
			var ctr = sfc.constructor;
			if (ctr != null && !ctr.isStructField) {
				var _ctr_name = ctr.name;
				var _ctr_isInst = ctr.isInst;
				// new [if we have child classes that'll call it via super()]:
				if (sfc.children.length > 0 || sfc.meta.has(":gml.keep.new")) {
					ctr.name = "new";
					ctr.isInst = true;
					addFunc(ctr.getPathAuto(), null, ctr);
				}
				// create:
				ctr.name = ctr.metaGetText(ctr.meta, ":native");
				if (ctr.name == null) ctr.name = "create";
				ctr.isInst = false;
				var doc = ctr.getArgDoc(sfcd);
				if (doc != null && StringTools.endsWith(doc, ")")) {
					var s = sfc.metaString(":docName");
					if (s == null) s = sfc.name;
					doc += sprintf("->%s", s);
				}
				addFunc(ctr.getPathAuto(), doc, ctr);
				// restore state:
				ctr.name = _ctr_name;
				ctr.isInst = _ctr_isInst;
			} // ctr != null
			//
			for (sff in sfc.instList) if (!sff.isHidden) switch (sff.kind) {
				case FVar(_get, _set): {
					if (sff.index < 0) continue;
					var show = sff.checkDocState(sfcd);
					if (!show) continue;
					var doc = sff.doc;
					switch (sff.kind) {
						case FVar(AccNormal, AccNormal | AccNo | AccNever): {
							addMacro(sff.getPathAuto(), Std.string(sff.index), show,
								(_set != AccNormal ? "(read-only) " : "(index) ") + doc, sff);
						};
						default: {
							if (sff.docState > 0) Context.warning(
								'Can\'t expose an instance variable with ($_get, $_set)',
								sff.classField.pos);
						};
					}
				};
				case FMethod(_): {
					// we don't want extension definitions for Class:func()
					if (sff.isStructField) continue;
					addFunc(sff.getPathAuto(), sff.getArgDoc(sfcd), sff);
				};
			}
			//
		} // addClass
		function addEnum(sfe:SfEnum) {
			var edoc = sfe.docState;
			if (sfe.isHidden && edoc <= 0) return;
			var nativeGen = sfe.nativeGen;
			for (sfec in sfe.ctrList) if (!sfec.isHidden) {
				var sfcd = sfec.docState;
				var show = sfec.checkDocState(edoc);
				var mcr = show || nativeGen;
				var sfb = new SfBuffer();
				sfb.addFieldPathAuto(sfec);
				var path = sfb.toString();
				var doc = sfec.doc;
				if (sfe.noRef || sfec.args.length > 0) {
					var comp:String = null;
					if (show) {
						var fb = new SfBuffer();
						printf(fb, "%s(", path);
						var args = sfec.args;
						for (i in 0 ... args.length) {
							if (i > 0) printf(fb, ", ");
							printf(fb, "%s:%base_type", args[i].v.name, args[i].v.type);
						}
						printf(fb, ")");
						if (doc != "") printf(fb, " : %s", doc);
						comp = fb.toString();
					}
					addFunc(path, comp, sfec);
				} else {
					if (sfe.isFake) {
						if (mcr) addMacro(path, "" + sfec.index, show, doc, sfec);
					} else {
						addFunc("mc_" + path, null, sfec);
						if (mcr) addMacro(path, "g_" + path, show, doc, sfec);
					}
				}
			}
		} // addEnum
		function addAbstract(sfa:SfAbstract) {
			if (!sfa.needsMacros()) return;
			// enum abstract?
			var sfad = sfa.docState;
			for (sff in sfa.impl.staticList) {
				if (!sff.meta.has(":enum")) continue;
				if (!sff.checkDocState(sfad)) continue;
				if (sff.expr == null) continue;
				var b1 = new SfBuffer(); b1.addFieldPathAuto(sff);
				var b2 = new SfBuffer(); b2.addExpr(sff.expr, SfPrintFlags.ExprWrap);
				addMacro(b1.toString(), b2.toString(), true, sff.doc, sff);
			}
		}
		function addAnon(sfq:SfAnon) {
			if (sfq.isHidden) return;
			var sfqd = sfq.docState;
			for (sff in sfq.fields) {
				if (!sff.checkDocState(sfqd)) continue;
				var b1 = new SfBuffer(); b1.addFieldPathAuto(sff);
				addMacro(b1.toString(), Std.string(sff.index), true, sff.doc, sff);
			}
		}
		for (t in sfGenerator.typeList) {
			if (Std.is(t, SfClass)) {
				addClass(cast t);
			} else if (Std.is(t, SfEnum)) {
				addEnum(cast t);
			} else if (Std.is(t, SfAbstract)) {
				addAbstract(cast t);
			} else if (Std.is(t, SfAnon)) {
				addAnon(cast t);
			}
		}
	}
	public static function run(xmlPath:String) {
		var sfg:SfGenerator = SfCore.sfGenerator;
		var gd:Bool = SfCore.sfConfig.gmxDoc;
		var md:Bool = SfCore.sfConfig.gmxMcrDoc;
		var skipFuncs = sfConfig.codePath != null;
		var sfb:SfBuffer;
		function xmlFind(xml:Xml, name:String):Xml {
			var iter = xml.elementsNamed(name);
			if (!iter.hasNext()) {
				Context.error('Could not find <$name> in the GMX.',
				Context.makePosition({ file: xmlPath, min: 0, max: 0 }));
			}
			return iter.next();
		}
		function xmlRead(xml:Xml):String {
			return xml.firstChild().toString();
		}
		var path_in = xmlPath;
		if (!FileSystem.exists(path_in) && FileSystem.exists(path_in + ".base")) path_in += ".base";
		var text:String = File.getContent(path_in);
		//{
		var xmlRoot:Xml = haxe.xml.Parser.parse(text);
		var extNode:Xml = xmlFind(xmlRoot, "extension");
		var extName:String = xmlRead(xmlFind(extNode, "name"));
		var extFiles:Xml = xmlFind(extNode, "files");
		var fileNode:Xml = null;
		var fileName:String = SfCore.sfConfig.gmxFile;
		if (fileName != null) {
			for (fileIter in extFiles.elementsNamed("file")) {
				if (xmlRead(xmlFind(fileIter, "filename")) == fileName) {
					fileNode = fileIter;
					break;
				}
			}
			if (fileNode == null) Context.error(
				'Could not find file `$fileName` in the GMX.',
				Context.makePosition({ file: xmlPath, min: 0, max: 0 })
			);
		} else {
			for (fileIter in extFiles.elementsNamed("file")) {
				var name = xmlRead(xmlFind(fileIter, "filename"));
				if (Path.extension(name).toLowerCase() == "gml") {
					fileNode = fileIter;
					fileName = name;
					break;
				}
			}
			if (fileNode == null) Context.error(
				'Could not find file any GML files in the GMX.',
				Context.makePosition({ file: xmlPath, min: 0, max: 0 })
			);
		}
		//
		if (sfConfig.codePath == null) {
			var extDir = Path.directory(xmlPath) + "/" + extName;
			if (!FileSystem.exists(extDir)) FileSystem.createDirectory(extDir);
			var filePath:String = extDir + "/" + fileName;
			sfg.printTo(filePath);
		} else sfg.printTo(sfConfig.codePath);
		//}
		//{ Fill out <functions> and <constants> nodes:
		var lbt:String = "\r\n      ";
		var lb0:String = "\r\n        ";
		var lb1:String = "\r\n          ";
		var lb2:String = "\r\n            ";
		var extFuncs:Xml = Xml.createElement("functions");
		var extMacro:Xml = Xml.createElement("constants");
		var extFuncsOld:Xml = xmlFind(fileNode, "functions");
		var extMacroOld:Xml = xmlFind(fileNode, "constants");
		/** Adds text to a node. */
		inline function addText(xml:Xml, text:String):Void {
			xml.addChild(Xml.createPCData(text));
		}
		var addParNode:Xml;
		/** Adds a `<name/>` to Xml.*/
		inline function addNode(xml:Xml, name:String):Xml {
			// add a linebreak+indent:
			xml.addChild(Xml.createPCData(lb0));
			// create and add the actual node:
			addParNode = Xml.createElement(name);
			xml.addChild(addParNode);
			return addParNode;
		}
		/** Adds a `<name>text</name>` to Xml. */
		inline function addParam(xml:Xml, name:String, ?text:String):Xml {
			// add a linebreak+indent:
			xml.addChild(Xml.createPCData(lb1));
			// create and add the actual node:
			addParNode = Xml.createElement(name);
			if (text != null) addParNode.addChild(Xml.createPCData(text));
			xml.addChild(addParNode);
			return addParNode;
		}
		function addMacro(name:String, value:String, doc:String) {
			var mcrNode = addNode(extMacro, "constant");
			addParam(mcrNode, "name", name);
			addParam(mcrNode, "value", value);
			addParam(mcrNode, "hidden", doc == null ? "-1" : "0");
			addText(mcrNode, lb0);
			// additional documentation node:
			if (gd && md && doc != null && doc != "") {
				mcrNode = addNode(extMacro, "constant");
				addParam(mcrNode, "name", name + ' /* $doc */');
				addParam(mcrNode, "value", value);
				addParam(mcrNode, "hidden", "0");
				addText(mcrNode, lb0);
			}
		}
		function addFunc(name:String, doc:String, sff:SfField) {
			if (skipFuncs) return;
			var argc:Int = sff.args != null ? sff.args.length : 0;
			if (argc > 0) {
				var last = sff.args[argc - 1];
				var ttype = last.v.type;
				while (true) switch (ttype) {
					case TType(_.get() => { type: t}, _): ttype = t;
					default: break;
				}
				switch (ttype) {
					case TAbstract(_.get() => { name: "SfRest" }, _): argc = -1;
					default: if (last.value != null) argc = -1;
				}
			}
			if (argc >= 0 && Std.is(sff, SfClassField)) {
				var sfcf:SfClassField = cast sff;
				if (sfcf.isInst) argc += 1;
			}
			var funNode = addNode(extFuncs, "function");
			addParam(funNode, "name", name);
			addParam(funNode, "externalName", name);
			addParam(funNode, "kind", "11"); // doesn't matter for GML scripts
			addParam(funNode, "help", gd && doc != null ? doc : "");
			addParam(funNode, "returnType", "2"); // again, doesn't matter for GML scripts
			addParam(funNode, "argCount", Std.string(argc));
			var funArgs = addParam(funNode, "args");
			if (argc > 0) {
				for (i in 0 ... argc) {
					addText(funArgs, lb2);
					var funArg = Xml.createElement("arg");
					addText(funArg, "2");
					funArgs.addChild(funArg);
				}
				addText(funArgs, lb1);
			}
			addText(funNode, lb0);
		}
		if (!skipFuncs && sfConfig.entrypoint != "") { // entrypoint
			var epNode = addNode(extFuncs, "function");
			addParam(epNode, "name", SfCore.sfConfig.entrypoint);
			addParam(epNode, "externalName", SfCore.sfConfig.entrypoint);
			addParam(epNode, "kind", "11");
			addParam(epNode, "help", "");
			addParam(epNode, "returnType", "2");
			addParam(epNode, "argCount", "0");
			addParam(epNode, "args");
			addText(epNode, lb0);
		}
		iter(addFunc, addMacro);
		//}
		//{ Replace <functions> and <constants> nodes with new ones:
		if (extFuncs.firstChild() != null) extFuncs.addChild(Xml.createPCData(lbt));
		if (extMacro.firstChild() != null) extMacro.addChild(Xml.createPCData(lbt));
		var extNodes:Int = 0;
		for (node in fileNode) {
			if (node == extFuncsOld) {
				fileNode.insertChild(extFuncs, extNodes);
				fileNode.removeChild(extFuncsOld);
			} else if (node == extMacroOld) {
				fileNode.insertChild(extMacro, extNodes);
				fileNode.removeChild(extMacroOld);
			}
			extNodes += 1;
		}
		//}
		File.saveContent(xmlPath, xmlRoot.toString());
	}
	
}
