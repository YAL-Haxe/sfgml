package sf.type;

import haxe.macro.Type.ClassType;
import sf.SfCore.*;
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
	
	/** Classes marked `@:std` get unprefixed variable access. */
	public var isStd:Bool;
	
	/** */
	public var objName:String = null;
	
	public function new(t:ClassType) {
		super(t);
		isStd = t.meta.has(":std");
		objName = metaGetText(t.meta, ":object", 2);
		if (objName == "") {
			var sb = new SfBuffer();
			sb.addTypePathAuto(this);
			objName = sb.toString();
		}
		if (sfConfig.dynMethods) for (fd in instList) switch (fd.kind) {
			case FMethod(_): {
				fd.isVar = true;
				fd.isDynFunc = true;
			};
			default:
		}
		if (t.meta.has(":noRefWrite")) for (fd in fieldList) fd.noRefWrite = true;
	}
	
	override public function removeField(field:SfClassField):Void {
		super.removeField(field);
		if (field != null && field.index >= 0) fieldsByIndex[field.index] = null;
	}
	
	static function printFieldExpr(r:SfBuffer, f:SfClassField) {
		sfGenerator.currentField = f;
		var c = sfConfig.printIf;
		if (c != null) printf(r, "if (%s) {%(+\n)", c);
		#if (sfgml_tracecall)
		printf(r, 'tracecall("+ %(field_auto)");\n', f);
		#end
		var x = f.expr;
		printf(r, "%;%(stat);", x);
		#if (sfgml_tracecall)
		if (!x.endsWithExits()) printf(r, '\ntracecall("- %(field_auto)",`0);', f);
		#end
		if (c != null) {
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
		r.addLine();
		sfGenerator.currentField = null;
	}
	
	private function printConstructor(r:SfBuffer, ctr:SfClassField):Void {
		var ctr_isInst = ctr.isInst;
		var ctr_name = ctr.name;
		var ctr_path = {
			var b = new SfBuffer();
			b.addFieldPathAuto(ctr);
			b.toString();
		};
		
		// _new, if this has children:
		var sepNew = children.length > 0 || meta.has(":gml.keep.new");
		if (sepNew) {
			ctr.isInst = true; ctr.name = "new";
			printf(r, "\n#define %s\n", ctr_path);
			SfArgVars.doc(r, ctr);
			SfArgVars.print(r, ctr);
			printFieldExpr(r, ctr);
		}
		
		//
		var ctr_native = ctr.metaGetText(ctr.meta, ":native");
		ctr.isInst = false; ctr.name = (ctr_native != null ? ctr_native : "create");
		printf(r, "\n#define %(field_auto)\n", ctr);
		SfArgVars.doc(r, ctr);
		//
		if (objName != null) {
			// it's instance-based
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
		else {
			inline function printMeta(r:SfBuffer):Void {
				if (module == sf.opt.SfGmlType.mtModule) {
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
		
		// add dynamic functions:
		var dynFound = new Map();
		var iterClass = this;
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
					if (!isStd) r.addString("f_");
					r.addFieldPathAuto(iterField);
				} else printf(r, "undefined");
				printf(r, ";\n");
			}
			iterClass = iterClass.superClass;
		}
		
		if (!sepNew) {
			SfArgVars.print(r, ctr);
			printFieldExpr(r, ctr);
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
					printf(r, "\ncase %d:`%s(this", arc, ctr_path);
					ai = 0;
					while (ai < arc) {
						printf(r, ",`argument[%d]", ai);
						ai++;
					}
					printf(r, ");`break;");
					arc++;
				}
				printf(r, '\ndefault:`show_error("Expected %d..%d arguments.",`true);', areq, argc);
				r.addLine( -1);
				printf(r, "}\n");
			} else {
				printf(r, "%s(this", ctr_path);
				ai = -1;
				while (++ai < argc) {
					printf(r, ",`argument[%d]", ai);
				}
				printf(r, ");\n");
			}
		}
		
		//
		printf(r, "return this;\n");
		ctr.isInst = ctr_isInst; ctr.name = ctr_name;
	}
	override public function printTo(out:SfBuffer, initBuf:SfBuffer):Void {
		var hintFolds = sfConfig.hintFolds;
		var r:SfBuffer = null;
		var init:SfBuffer = null;
		if (!isHidden) {
			var nativeGen = this.nativeGen;
			sfGenerator.currentClass = this;
			r = new SfBuffer();
			init = new SfBuffer();
			// hint-enum:
			if (docState > 0 && !sfConfig.gmxMode) {
				var fb = new SfBuffer();
				var fn = 0;
				for (f in instList) if (f.index >= 0) {
					if (fn > 0) fb.addComma();
					printf(fb, "%s`=`%d", f.name, f.index);
					fn += 1;
				}
				if (fn > 0) printf(init, "enum %(type_auto)`{`%s`};\n", this, fb.toString());
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
						printf(init, "globalvar g_%s;`", path);
						printf(init, "g_%s`=`", path);
						if (f.expr == null || f.expr.def.match(SfConst(TNull))) {
							init.addString("undefined");
							fbody = false;
						} else init.addString(path);
						printf(init, ";\n");
					}
					// function cc_yal_Some_field(...) { ... }
					if (fbody) {
						printf(r, "\n#define %s\n", path);
						SfArgVars.doc(r, f);
						SfArgVars.print(r, f);
						printFieldExpr(r, f);
					}
					//
				}; // static function
				case FVar(_, _): { // static var
					// var cc_yal_Some_field[ = value];
					init.addString("globalvar ");
					if (!this.isStd) init.addString("g_");
					init.addFieldPathAuto(f);
					init.addSemico();
					var fx:SfExpr = f.expr;
					if (fx != null) {
						var fd = fx.getData();
						var fsf = fx.mod(SfStaticField(this, f));
						switch (fx.def) {
							case SfBlock(w): { // v = { ...; x; } -> { ...; v = x; }
								init.addLine();
								var wn = w.length;
								var wx = w.slice(0, wn - 1);
								wx.push(fx.mod(SfBinop(OpAssign, fsf, w[wn - 1])));
								fx = fx.mod(SfBlock(wx));
							};
							default: {
								init.addSep();
								fx = fx.mod(SfBinop(OpAssign, fsf, fx));
							};
						}
						init.addExpr(fx, false); printf(init, ";\n");
					} else init.addLine();
				};
			}
			// constructor:
			var ctr = constructor;
			if (ctr != null && !ctr.isHidden) {
				printConstructor(r, ctr);
			}; // constructor
			
			// instance functions:
			for (fd in instList) if (!fd.isHidden && fd.isCallable && fd.expr != null) {
				printf(r, "\n#define %(field_auto)\n", fd);
				SfArgVars.doc(r, fd);
				SfArgVars.print(r, fd);
				printFieldExpr(r, fd);
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
