package sf.type;

import haxe.macro.Type.AbstractType;
import sf.type.SfBuffer;

/**
 * ...
 * @author YellowAfterlife
 */
class SfAbstract extends SfAbstractImpl {
	
	public function new(t:AbstractType) {
		super(t);
	}
	
	override public function printTo(out:SfBuffer, init:SfBuffer):Void {
		/*out.addString("var ");
		out.addTypePathAuto(this);
		out.addSepChar("=".code);
		out.addBlockOpen();
		out.addSep();
		out.addBlockClose();
		out.addLine();*/
	}
	
}
