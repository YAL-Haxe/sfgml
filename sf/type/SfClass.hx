package sf.type;

import haxe.macro.Type.ClassType;
import sf.SfCore.*;
import sf.opt.syntax.SfGmlWith;
import sf.type.SfBuffer;
import sf.type.SfClass;
import sf.type.SfClassField;
import sf.type.expr.*;
import sf.type.expr.SfExprDef.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfClass extends SfClassImpl {
	
	/** Total number of indexes given to this class' fields */
	public var indexes:Int = -1;
	
	public var fieldsByIndex:Array<SfClassField> = [];
	
	/** If this is based on an object instance, indicates object to create */
	public var objName:String = null;
	
	public function new(t:ClassType) {
		super(t);
		//
		objName = metaGetText(t.meta, ":object", 2);
		if (objName == "") {
			var sb = new SfBuffer();
			sb.addTypePathAuto(this);
			objName = sb.toString();
		}
		if (objName != null) {
			isStruct = false;
			dotAccess = true;
		}
		//
		if (!sfConfig.modern) {
			if (sfConfig.dynMethods) for (fd in instList) switch (fd.kind) {
				case FMethod(_): {
					fd.isVar = true;
					fd.isDynFunc = true;
				};
				default:
			}
		}
		// if we do .field, we do not want them named same as built-in variables:
		if (dotAccess) for (fd in instList) {
			var s0 = fd.name;
			var s1 = sfGenerator.getFieldName(s0);
			if (s0 != s1) fd.name = s1;
		}
		// ditto for statics if we dot .static:
		if (dotStatic) for (fd in staticList) {
			var s0 = fd.name;
			var s1 = sfGenerator.getFieldName(s0);
			if (s0 != s1) fd.name = s1;
		}
		//
		if (t.meta.has(":noRefWrite")) for (fd in fieldList) fd.noRefWrite = true;
	}
	
	override public function removeField(field:SfClassField):Void {
		super.removeField(field);
		if (field != null && field.index >= 0) fieldsByIndex[field.index] = null;
	}
	
	static function printFieldExpr(r:SfBuffer, f:SfClassField) {
		sfGenerator.currentField = f;
		var printCond = sfConfig.printIf;
		if (printCond != null) printf(r, "if (%s) {%(+\n)", printCond);
		#if (sfgml_tracecall)
		printf(r, 'tracecall("+ %(field_auto)");\n', f);
		#end
		var x = f.expr;
		
		var oldSelfLevel = sfGenerator.selfLevel;
		sfGenerator.selfLevel = f.isSelfCall() ? 0 : -1;
		printf(r, "%;%sw;", x);
		sfGenerator.selfLevel = oldSelfLevel;
		
		#if (sfgml_tracecall)
		if (!x.endsWithExits()) printf(r, '\ntracecall("- %(field_auto)",`0);', f);
		#end
		if (printCond != null) {
			printf(r, "%(-\n)}");
			var v = f.metaGetText(f.meta, ":defValue");
			if (v == null) v = switch (f.type) {
				case TAbstract(_.get() => { name: "Void" }, _): null;
				case TAbstract(_.get() => { name: "Int"|"Float" }, _): "0";
				case TAbstract(_.get() => { name: "Bool" }, _): "false";
				default: "undefined";
			}
			if (v != null) printf(r, " else return %s;", v);
		}
		sfGenerator.currentField = null;
	}
	
	public function needsSeparateNewFunc():Bool {
		return children.length > 0 || meta.has(":gml.keep.new");
	}
	
	private function printConstructor(r:SfBuffer, ctr:SfClassField, ignoreFields:Map<String, Bool>):Void {
		var ctr_isInst = ctr.isInst;
		var ctr_name = ctr.name;
		var ctr_path = {
			var b = new SfBuffer();
			b.addFieldPathAuto(ctr);
			b.toString();
		};
		
		// _new, if this has children:
		var sepNew = needsSeparateNewFunc();
		if (sepNew) {
			ctr.isInst = true; ctr.name = "new";
			r.addTopLevelFuncOpenField(ctr);
			SfArgVars.doc(r, ctr);
			SfArgVars.print(r, ctr);
			printFieldExpr(r, ctr);
			r.addTopLevelFuncClose();
		}
		
		//
		ctr.isInst = false;
		var ctr_exposePath:String;
		if (isStruct) {
			if (dotStatic) {
				printf(r, "\nglobalvar %type_auto;", this);
				printf(r, "`%type_auto = method(undefined,`function(", this);
			} else {
				printf(r, "\nfunction %(type_auto)(", this);
			}
			r.addArguments(ctr.args);
			printf(r, ")`constructor`{%(+\n)", this);
			ctr_exposePath = ctr.exposePath;
			ctr.exposePath = {
				var b = new SfBuffer();
				b.addTypePathAuto(this);
				b.toString();
			};
		} else {
			var ctr_native = ctr.metaGetText(ctr.meta, ":native");
			ctr.name = (ctr_native != null ? ctr_native : "create");
			r.addTopLevelFuncOpenField(ctr);
		}
		SfArgVars.doc(r, ctr);
		if (isStruct) ctr.exposePath = ctr_exposePath;
		
		// generate initalizer:
		if (isStruct) {
			if (SfGmlWith.needsThisSelf(ctr.expr)) printf(r, "var this`=`self;\n");
		}
		else if (objName != null) { // it's instance-based
			if (sfConfig.next) {
				printf(r, "var this`=`instance_create_depth(0,`0,`0,`%s);\n", objName);
			} else {
				printf(r, "var this`=`instance_create(0,`0,`%s);\n", objName);
			}
			if (!nativeGen) printf(r, "this.__class__`=`mt_%(type_auto);\n", this);
		}
		else if (nativeGen && !sfConfig.fieldNames) {
			// it's :nativeGen and we don't need field labels
			// so we allocate the container and call it a day
			printf(r, "var this");
			if (sfConfig.hasArrayCreate) {
				printf(r, "`=`array_create(%d);\n", indexes);
			} else printf(r, ";`this[%d]`=`0;\n", indexes - 1);
		}
		else { // normal linear
			inline function printMeta(r:SfBuffer):Void {
				if (module == sf.opt.type.SfGmlType.mtModule) {
					// if we are inside gml.MetaType.* constructors,
					// we just embed the name because otherwise they are going to use themselves
					printf(r, '"mt_%(type_auto)"', this);
				} else printf(r, "mt_%(type_auto)", this);
			}
			//
			printf(r, "var this");
			var protoCopyOffset:Int = 0;
			if (nativeGen) {
				// it has no meta so we want an empty array
				if (sfConfig.hasArrayDecl) {
					printf(r, "`=`[]");
				} else if (sfConfig.hasArrayCreate) {
					printf(r, "`=`array_create(0)");
				} else printf(r, ";`this[0]`=`0");
			} else if (sfConfig.legacyMeta) {
				// it has legacy meta so we set that, at the same time creating the array
				printf(r, ";`this[1,0%(hint)]`=`", "metatype");
				printMeta(r);
			} else {
				// we initialize the array to have the meta as the first item
				// and skip that item when copying from prototype
				protoCopyOffset = 1;
				if (sfConfig.hasArrayDecl) {
					printf(r, "`=`[");
					printMeta(r);
					printf(r, "]");
				} else {
					printf(r, ";`this[0%(hint)]`=`", "metatype");
					printMeta(r);
				}
			}
			printf(r, ";\n");
			// finally, if we need to, array_copy the protoype into the resulting structure.
			if (indexes > protoCopyOffset) printf(r,
				"array_copy(this,`%d,`mq_%(type_auto),`%d,`%d);\n",
				protoCopyOffset, this, protoCopyOffset, indexes - protoCopyOffset
			);
		}
		
		if (isStruct) { // add prototype fields
			var iterFound = new Map();
			var iterClass = this;
			var checkInsert = children.length == 0;
			var iterLayer = 0;
			while (iterClass != null) {
				for (iterField in iterClass.instList) {
					if (iterField.isHidden) continue;
					var iterName = iterField.name;
					if (iterFound.exists(iterName)) continue;
					iterFound[iterName] = true;
					//
					printf(r, "static %s`=`", iterName);
					if (iterField.needsFunction()) {
						if (checkInsert) {
							printf(r, "function(");
							r.addThisArguments(false, iterField.args);
							printf(r, ")`{%(+\n)");
							SfArgVars.print(r, iterField);
							printFieldExpr(r, iterField);
							printf(r, "%(-\n)}");
							ignoreFields[iterField.realName] = true;
						} else printf(r, "method(undefined,`%(field_auto))", iterField);
					} else {
						printf(r, "undefined");
					}
					printf(r, ";\n");
				}
				iterClass = iterClass.superClass;
				checkInsert = false;
			}
		}
		else { // add dynamic functions
			var dynFound = new Map();
			var iterClass = this;
			var refs = sf.opt.legacy.SfGmlScriptRefs.enabled;
			while (iterClass != null) {
				for (iterField in iterClass.instList) {
					if (!iterField.isDynFunc) continue;
					if (iterField.expr == null && objName == null) continue;
					var iterName = iterField.name;
					if (dynFound.exists(iterName)) continue;
					dynFound.set(iterName, true);
					//
					if (objName != null) {
						printf(r, "this.%s`=`", iterField.name);
					} else {
						printf(r, "this[@%d%(hint)]`=`", iterField.index, iterField.name);
					}
					//	
					if (iterField.expr != null) {
						if (!isStd && refs) r.addString("f_");
						r.addFieldPathAuto(iterField);
					} else printf(r, "undefined");
					printf(r, ";\n");
				}
				iterClass = iterClass.superClass;
			}
		}
		
		if (!sepNew) { // merge constructor implementation in here
			SfArgVars.print(r, ctr);
			printFieldExpr(r, ctr);
			r.addLine();
		} else {
			//
			var args = ctr.args;
			var argc = args.length;
			var areq = -1;
			while (++areq < argc) if (args[areq].value != null) break;
			//
			var ai:Int;
			if (areq != argc) { // optional arguments, aren't they fun
				printf(r, "switch`(argument_count)`{");
				r.indent += 1;
				var arc = areq;
				while (arc <= argc) {
					var asep:Bool;
					printf(r, "\ncase %d:`", arc);
					if (isStruct) {
						printf(r, "method(self, %s)(", ctr_path);
						asep = false;
					} else {
						printf(r, "%s(this", ctr_path);
						asep = true;
					}
					ai = 0;
					while (ai < arc) {
						if (asep) printf(r, ",`"); else asep = true;
						printf(r, "argument[%d]", ai);
						ai++;
					}
					printf(r, ");`break;");
					arc++;
				}
				printf(r, '\ndefault:`show_error("Expected %d..%d arguments.",`true);', areq, argc);
				r.addLine( -1);
				printf(r, "}\n");
			} else {
				var asep:Bool;
				if (isStruct) {
					printf(r, "method(self, %s)(", ctr_path);
					asep = false;
				} else {
					printf(r, "%s(this", ctr_path);
					asep = true;
				}
				ai = -1;
				while (++ai < argc) {
					if (asep) printf(r, ",`"); else asep = true;
					printf(r, "argument[%d]", ai);
				}
				printf(r, ");\n");
			}
		}
		
		//
		if (isStruct) {
			if (nativeGen) {
				printf(r, "//");
			} else {
				printf(r, "static __class__`=`");
				if (module == sf.opt.type.SfGmlType.mtModule) {
					printf(r, '"%s";', name);
				} else printf(r, "mt_%(type_auto);", this);
			}
		} else {
			printf(r, "return this;");
		}
		r.addTopLevelFuncCloseField(ctr, dotStatic);
		if (isStruct && !nativeGen) {
			var mtc = sfGenerator.findRealClassField("gml.MetaClass", "constructor");
			if (mtc != null) {
				printf(r, "mt_%type_auto.%s`=`%type_auto;\n", this, mtc.name, this);
			}
		}
		ctr.isInst = ctr_isInst; ctr.name = ctr_name;
	}
	
	override public function printTo(out:SfBuffer, initBuf:SfBuffer):Void {
		var hintFolds = sfConfig.hintFolds;
		var r:SfBuffer = null;
		var init:SfBuffer = null;
		var modern = sfConfig.modern;
		var ignoreFields = new Map<String, Bool>();
		if (!isHidden) {
			var g_ = modern ? "" : "g_";
			var nativeGen = this.nativeGen;
			sfGenerator.currentClass = this;
			r = new SfBuffer();
			init = new SfBuffer();
			// hint-enum:
			if (docState > 0 && !dotAccess && !sfConfig.gmxMode) {
				var fb = new SfBuffer();
				var fn = 0;
				for (f in instList) if (f.index >= 0) {
					if (fn > 0) fb.addComma();
					printf(fb, "%s`=`%d", f.name, f.index);
					fn += 1;
				}
				if (fn > 0) printf(init, "enum %(type_auto)`{`%s`};\n", this, fb.toString());
			}
			
			// constructor:
			var ctr = constructor;
			if (ctr != null && !ctr.isHidden) {
				printConstructor(r, ctr, ignoreFields);
			} else if (dotStatic) {
				var hasStatics = false;
				for (f in staticList) {
					if (!f.isHidden) { hasStatics = true; break; }
				}
				if (hasStatics) printf(r, "globalvar %type_auto;`%type_auto`=`{};\n", this, this);
			}
			
			// static fields:
			for (f in staticList) if (!f.isHidden) switch (f.kind) {
				case FMethod(_): { // static function
					var path:String = {
						var b = new SfBuffer();
						b.addFieldPathAuto(f);
						b.toString();
					};
					var fbody = true;
					if (f.isVar) { // dynamic fields get a variable
						printf(init, "globalvar %s%s;`", g_, path);
						printf(init, "%s%s`=`", g_, path);
						if (f.expr == null || f.expr.def.match(SfConst(TNull))) {
							init.addString("undefined");
							fbody = false;
						} else init.addString(path);
						printf(init, ";\n");
					}
					// function cc_yal_Some_field(...) { ... }
					if (fbody) {
						r.addTopLevelFuncOpenField(f);
						SfArgVars.doc(r, f);
						SfArgVars.print(r, f);
						printFieldExpr(r, f);
						r.addTopLevelFuncCloseField(f);
					}
					//
				}; // static function
				case FVar(_, _): { // static var
					// var cc_yal_Some_field[ = value];
					if (!dotStatic) printf(init, "globalvar %s%(field_auto);", g_, f);
					var fx:SfExpr = f.expr;
					if (fx != null) {
						var fd = fx.getData();
						var fsf = fx.mod(SfStaticField(this, f));
						switch (fx.def) {
							case SfBlock(w): { // v = { ...; x; } -> { ...; v = x; }
								init.addLine();
								var wn = w.length;
								var wx = w.slice(0, wn - 1);
								if (modern) {
									wx.push(fx.mod(SfReturn(true, w[wn - 1])));
									fx = fx.mod(SfBlock(wx));
									printf(init, "%s%(field_auto)`=`(function()`{", g_, f);
									printf(init, "%(+\n)%sw;%(-\n)})();\n", fx);
								} else {
									wx.push(fx.mod(SfBinop(OpAssign, fsf, w[wn - 1])));
									fx = fx.mod(SfBlock(wx));
									printf(init, "%sw;\n", fx);
								}
							};
							default: {
								init.addSep();
								fx = fx.mod(SfBinop(OpAssign, fsf, fx));
								printf(init, "%sw;\n", fx);
							};
						}
					} else init.addLine();
				};
			}
			
			// instance functions:
			for (fd in instList) if (fd.needsFunction()) {
				if (ignoreFields[fd.realName]) continue;
				r.addTopLevelFuncOpenField(fd);
				SfArgVars.doc(r, fd);
				SfArgVars.print(r, fd);
				printFieldExpr(r, fd);
				r.addTopLevelFuncClose();
			}
			//
			sfGenerator.currentClass = null;
		} // if (!isHidden)
		var rc = r;
		r = out;
		if (rc != null && rc.length > 0) {
			if (hintFolds) printf(r, "\n//{`%(type_dot)\n", this);
			r.addBuffer(rc);
			if (hintFolds) printf(r, "\n//}\n");
		}
		if (init != null && init.length > 0) {
			if (hintFolds) printf(initBuf, "// %(type_dot):\n", this);
			initBuf.addBuffer(init);
		}
	}
}
