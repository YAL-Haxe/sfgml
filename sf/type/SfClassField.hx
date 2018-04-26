package sf.type;

/**
 * ...
 * @author YellowAfterlife
 */
class SfClassField extends SfClassFieldImpl {
	public var index:Int = -1;
	public function getArgDoc():String {
		if (doc != null) {
			var sfb = new SfBuffer();
			SfArgVars.doc(sfb, this, 4);
			return sfb.toString();
		} else return null;
	}
}
