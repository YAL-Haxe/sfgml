package sf.type;

/**
 * ...
 * @author YellowAfterlife
 */
class SfField extends SfFieldImpl {
	public function getPathAuto():String {
		var b = new SfBuffer();
		b.addFieldPathAuto(this);
		return b.toString();
	}
}
