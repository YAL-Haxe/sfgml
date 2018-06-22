package sf.type;

import haxe.macro.Type.ClassType;
import sf.SfCore.*;
import sf.type.SfBuffer;
import sf.type.SfClass;
import sf.type.SfExprDef.*;
import SfTools.cfor;
using sf.type.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfClass extends SfClassImpl {
	
	/** Total number of indexes given to this class' fields */
	public var indexes:Int = -1;
	
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
			if (doc != null && !sfConfig.gmxMode) {
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
				var ctr_isInst = ctr.isInst;
				var ctr_name = ctr.name;
				var ctr_path = {
					var b = new SfBuffer();
					b.addFieldPathAuto(ctr);
					b.toString();
				};
				
				// _new, if this has children:
				if (children.length > 0) {
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
				if (objName != null) {
					#if (sfgml_next)
					printf(r, "var this`=`instance_create_depth(0,`0,`0,`%s);\n", objName);
					#else
					printf(r, "var this`=`instance_create(0,`0,`%s);\n", objName);
					#end
					if (!nativeGen) printf(r, "this.__class__`=`mt_%(type_auto);\n", this);
				} else if (nativeGen && !sfConfig.fieldNames) {
					printf(r, "var this");
					if (sfConfig.hasArrayCreate) {
						printf(r, "`=`array_create(%d);\n", indexes);
					} else printf(r, ";`this[%d]`=`0;\n", indexes - 1);
					
				} else {
					printf(r, "var this`=`mq_%(type_auto);\n", this);
					// add type id:
					if (nativeGen) {
						printf(r, "this[0%(hint)]`=`", "copyset");
						if (indexes > 0) {
							printf(r, "this[@0]");
						} else printf(r, "undefined");
					} else {
						printf(r, "this[1,0%(hint)]`=`", "metatype");
						if (module != sf.opt.SfGmlType.mtModule) {
							printf(r, "mt_%(type_auto)", this);
						} else r.addInt(index);
					}
					printf(r, ";\n");
				}
				
				// add dynamic functions (todo: check inheritance):
				for (f in instList) if (f.isDynFunc) {
					if (objName != null) {
						printf(r, "this.%s`=`", f.name);
					} else printf(r, "this[%d]`=`", f.index);
					if (f.expr != null) {
						if (isStd) r.addString("g_");
						r.addFieldPathAuto(f);
					} else printf(r, "undefined");
					printf(r, ";\n");
				}
				
				if (children.length <= 0) {
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
					if (areq != argc) {
						printf(r, "switch`(argument_count)`{");
						r.indent += 1;
						cfor(var arc = areq, arc <= argc, arc++, {
							printf(r, "\ncase %d:`%s(this%z);`break;", arc, ctr_path, {
								cfor(ai = 0, ai < arc, ai++, printf(r, ",`argument[%d]", ai));
							});
						});
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
