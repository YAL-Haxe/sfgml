package sf.type;
import sf.SfCore;

/**
 * ...
 * @author YellowAfterlife
 */
class SfEnumCtr extends SfEnumCtrImpl {
	/**
	 * Is it okay to reference this via enum_ctr?
	 */
	public function hasMacro():Bool {
		if (parentEnum.isExtern) return true;
		if (!parentEnum.isFake) return false;
		if (parentEnum.docState < 0) return false;
		if (!checkDocState(parentEnum.docState)) return false;
		if (parentEnum.hasNativeEnum()) return false;
		return true;
	}
	public function printIndexTo(b:SfBuffer):Void {
		if (parentEnum.hasNativeEnum()) {
			b.addTypePathAuto(parentEnum);
			b.addChar(".".code);
			b.addString(name);
		} else {
			b.addInt(index);
			b.addHintString(name);
		}
	}
}
