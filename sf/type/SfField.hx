package sf.type;
import sf.type.SfFieldImpl;

/**
 * ...
 * @author YellowAfterlife
 */
class SfField extends SfFieldImpl {
	
	/**
	 * Whether to use regular `fd[i]` instead of `fd[@i]` for array writes
	 * (primarily used for legacy format built-in variables)
	 */
	public var noRefWrite:Bool;
	
	public function new(t:SfType, f:TypeField) {
		super(t, f);
		noRefWrite = f.meta.has(":noRefWrite");
	}
	
	public function getPathAuto():String {
		var b = new SfBuffer();
		b.addFieldPathAuto(this);
		return b.toString();
	}
}
