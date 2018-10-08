package sf;
import haxe.io.Path;
import haxe.macro.Context;
import sf.type.SfBuffer;
import sf.type.SfClass;
import sf.type.SfClassField;
import sf.type.SfEnum;
import sf.type.SfField;
import sys.FileSystem;
import sys.io.File;
import sf.SfCore.*;
using sf.type.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmxGen {
	public static function iter(
		addFunc:String->String->SfField->Void,
		addMacro:String->String->String->Void
	) {
		var gd:Bool = SfCore.sfConfig.gmxDoc;
		var skipFuncs = sfConfig.codePath != null;
		//
		function addClass(sfc:SfClass) {
			if (sfc.isHidden) return;
			var sfcd = sfc.doc != null;
			//
			for (sff in sfc.staticList) if (!sff.isHidden) switch (sff.kind) {
				case FVar(_, _): {
					var path = sff.getPathAuto();
					var doc = sff.doc;
					var mcrValue = switch (sff.kind) {
						case FVar(AccInline, AccNo | AccNever): {
							sprintf("%x", sff.expr);
						};
						case FVar(AccCall, AccNo | AccNever): {
							if (doc == null) continue;
							var sfxName = "get_" + sff.name;
							var sfx = sfc.staticMap[sfxName];
							if (sfx != null) {
								var sfb = new SfBuffer();
								var sfxExpr = sfx.expr.unpack();
								switch ([sfx.kind, sfxExpr.def]) {
									case [FMethod(MethInline), SfReturn(true, v)]: {
										printf(sfb, "(%x)", v);
									};
									default: printf(sfb, "%(field_auto)()", sfx);
								}
								sfb.toString();
							} else {
								if (doc != null) {
									Context.warning("Can't find " + sfxName, sff.classField.pos);
								}
								null;
							}
						};
						default: {
							if (doc == null && !sfcd) continue;
							"g_" + path;
						};
					}; // mcrValue = switch(sff.kind)
					if (mcrValue != null) {
						if (doc != null && doc != "" || sfcd) {
							var sfb = new SfBuffer();
							printf(sfb, "(");
							sfb.addBaseTypeName(sff.type);
							printf(sfb, ") %s", doc);
							doc = sfb.toString();
						}
						addMacro(path, mcrValue, doc);
					}
				}; // FVar
				case FMethod(_): {
					addFunc(sff.getPathAuto(), sff.getArgDoc(sfcd), sff);
				};
			} // for (field in statics)
			//
			var ctr = sfc.constructor;
			if (ctr != null) {
				var ctrName = ctr.name;
				var ctrInst = ctr.isInst;
				// new:
				if (sfc.children.length > 0) {
					ctr.name = "new";
					ctr.isInst = true;
					addFunc(ctr.getPathAuto(), null, ctr);
				}
				// create:
				ctr.name = ctr.metaGetText(ctr.meta, ":native");
				if (ctr.name == null) ctr.name = "create";
				ctr.isInst = false;
				var doc = if (ctr.doc != null) {
					var sfb = new SfBuffer();
					SfArgVars.doc(sfb, ctr, 0);
					sfb.toString();
				} else null;
				addFunc(ctr.getPathAuto(), doc, ctr);
				//
				ctr.name = ctrName;
				ctr.isInst = ctrInst;
			} // ctr != null
			//
			for (sff in sfc.instList) if (!sff.isHidden) switch (sff.kind) {
				case FVar(_, _): {
					var doc = sff.doc;
					if ((doc != null || sfcd) && sff.index >= 0) switch (sff.kind) {
						case FVar(AccNormal, AccNormal): {
							addMacro(sff.getPathAuto(), Std.string(sff.index),
								doc != null ? "(index) " + doc : ""
							);
						};
						default:
					}
				};
				case FMethod(_): addFunc(sff.getPathAuto(), sff.getArgDoc(), sff);
			}
			//
		} // addClass
		function addEnum(sfe:SfEnum) {
			if (sfe.isHidden && sfe.doc == null) return;
			var edoc = sfe.doc;
			for (sfc in sfe.ctrList) if (!sfc.isHidden) {
				var sfb = new SfBuffer();
				sfb.addFieldPathAuto(sfc);
				var path = sfb.toString();
				var doc = sfc.doc;
				if (doc == null && edoc != null) doc = "";
				if (!gd) doc = null;
				if (sfe.noRef || sfc.args.length > 0) {
					var fb = new SfBuffer();
					if (doc != null) {
						printf(fb, "%s(", path);
						var args = sfc.args;
						for (i in 0 ... args.length) {
							if (i > 0) printf(fb, ", ");
							printf(fb, "%s:", args[i].v.name);
							fb.addBaseTypeName(args[i].v.type);
						}
						printf(fb, ")");
						if (doc != "") printf(fb, " : %s", doc);
					}
					addFunc(path, fb.toString(), sfc);
				} else if (sfe.isFake) {
					addMacro(path, "" + sfc.index, doc);
				} else {
					addFunc(path + "_new", null, sfc);
					addMacro(path, "g_" + path, doc);
				}
			}
		} // addEnum
		for (t in sfGenerator.typeList) {
			if (Std.is(t, SfClass)) {
				addClass(cast t);
			} else if (Std.is(t, SfEnum)) {
				addEnum(cast t);
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
			var filePath:String = Path.directory(xmlPath) + "/" + extName + "/" + fileName;
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
				switch (last.v.type) {
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
