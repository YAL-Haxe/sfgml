package sf.type;

import haxe.macro.Type.AnonType;
import haxe.macro.Type.DefType;
import sf.type.SfBuffer;
import sf.SfCore.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfAnon extends SfAnonImpl {
	public var indexes:Int = 0;
	public var indexMap:Map<String, Int> = new Map();
	public var isDsMap:Bool;
	public function new(t:DefType, at:AnonType) {
		super(t, at);
		isDsMap = meta.has(":dsMap");
		// https://github.com/HaxeFoundation/haxe/issues/4472
		for (fd in fields) {
			if (fd.meta.has(":native")) {
				fd.name = metaGetText(fd.meta, ":native");
			}
		}
	}
	override public function printTo(out:SfBuffer, init:SfBuffer):Void {
		if (nativeGen && doc != null && !sfConfig.gmxMode) {
			printf(init, "enum %(type_auto) {", this);
			var sep = false;
			for (f in fields) {
				if (sep) init.addComma(); else { sep = true; init.addSep(); }
				init.addString(f.name);
			}
			printf(init, "`}\n");
		}
	}
	public inline function printAnonFieldTo(out:SfBuffer, name:String, index:Int):Void {
		if (nativeGen && doc != null) {
			out.addTypePathAuto(this);
			out.addChar(sfConfig.gmxMode ? "_".code : ".".code);
			out.addString(name);
		} else {
			out.addInt(index);
			if (sfConfig.hint) out.addHintString(name);
		}
	}
}
