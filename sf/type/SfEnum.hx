package sf.type;
import haxe.macro.Type.MetaAccess;
import sf.type.SfBuffer;
import sf.SfCore.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfEnum extends SfEnumImpl {
	public var ctrNames:Bool = false;
	public function new(t) {
		super(t);
	}
	override public function printTo(outb:SfBuffer, initb:SfBuffer):Void {
		if (isHidden) return;
		if (isFake && nativeGen && !SfCore.sfConfig.gmxMode) {
			printf(initb, "enum %(type_auto) {", this);
			var sep = false;
			for (f in ctrList) {
				if (sep) initb.addComma(); else { sep = true; initb.addSep(); }
				initb.addString(f.name);
			}
			printf(initb, "`}\n");
		}
		if (isFake) return;
		var out = new SfBuffer(), init = new SfBuffer();
		var hintFolds = sfConfig.hintFolds;
		var debug = sfConfig.debug;
		var canRef = !this.noRef;
		var hasAC = sfConfig.hasArrayCreate;
		var pureArray = sfConfig.hasArrayDecl && nativeGen;
		var noScripts = pureArray && doc == null;
		for (ctr in ctrList) {
			var args:Array<SfArgument> = ctr.args;
			var argc:Int = args.length;
			var path:String = ctr.getPathAuto();
			if (argc == 0 && canRef) {
				printf(init, "globalvar g_%s;`", path);
				printf(init, "g_%s`=`", path);
				if (pureArray) {
					printf(init, "[%d%(hint)]", ctr.index, ctr.name);
				} else printf(init, "%s_new()", path);
				printf(init, ";\n");
				path += "_new";
			}
			if (noScripts) continue;
			printf(out, "\n#define %s\n", path);
			var i:Int = 0;
			if (!sfConfig.noCodeDoc) {
				printf(out, "/// %s(", path);
				while (i < argc) {
					if (i > 0) printf(out, ", ");
					printf(out, "%s:", args[i].v.name);
					out.addBaseTypeName(args[i].v.type);
					i += 1;
				}
				printf(out, ")\n");
			}
			//
			printf(out, "var this");
			if (hasAC) printf(out, "`=`array_create(%d)", argc);
			printf(out, ";\n");
			//
			if (!nativeGen) {
				if (debug) printf(out, 'this[1,1]`=`"%s";\n', ctr.name);
				printf(out, "this[1,0]`=`mt_%(type_auto);\n", this);
			}
			//
			i = argc;
			while (--i >= 0) {
				printf(out, "this[%d%(hint)]`=`argument[%d];\n", i + 1, args[i].v.name, i);
			}
			//
			printf(out, "this[0%(hint)]`=`%d;\n", "id", ctr.index);
			printf(out, "return this;\n");
		}
		if (out.length > 0) {
			if (hintFolds) printf(outb, "\n//{ %(type_dot)\n", this);
			outb.addBuffer(out);
			if (hintFolds) printf(outb, "\n//}\n");
		}
		if (init.length > 0) {
			if (hintFolds) printf(initb, "// %(type_dot):\n", this);
			initb.addBuffer(init);
		}
	}
}

