package sf.type;

import haxe.macro.Type.AbstractType;
import sf.SfConfig;
import sf.type.SfBuffer;
import sf.SfCore.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfAbstract extends SfAbstractImpl {
	
	public function new(t:AbstractType) {
		super(t);
	}
	
	public function needsMacros() {
		if (isHidden) return false;
		if (!meta.has(":enum")) return false;
		if (impl == null/* || impl.isHidden*/) return false;
		return true;
	}
	
	override public function printTo(out:SfBuffer, init:SfBuffer):Void {
		if (needsMacros() && !sfConfig.gmxMode && sfConfig.next) { // enum abstract?
			var sfad = docState;
			var hintFolds = sfConfig.hintFolds;
			var b = hintFolds ? new SfBuffer() : init;
			for (sff in impl.staticList) {
				if (!sff.meta.has(":enum")) continue;
				if (!sff.checkDocState(sfad)) continue;
				if (sff.expr == null) continue;
				printf(b, "#macro %field_auto %w\n", sff, sff.expr);
			}
			if (hintFolds && b.length > 0) {
				if (hintFolds) printf(init, "// %(type_dot):\n", this);
				init.addBuffer(b);
			}
		}
	}
	
}
