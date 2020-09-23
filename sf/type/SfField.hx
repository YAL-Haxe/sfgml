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
	
	/**
	 * @see SfType.dotAccess
	 */
	public var dotAccess(get, never):Bool;
	private inline function get_dotAccess():Bool {
		return parentType.dotAccess;
	}
	
	/**
	 * @see SfType.isStruct
	 */
	public var isStructField(get, never):Bool;
	private inline function get_isStructField():Bool {
		return parentType.isStruct;
	}
	
	public function new(t:SfType, f:TypeField) {
		super(t, f);
		noRefWrite = f.meta.has(":noRefWrite");
	}
	
	public function getPathAuto():String {
		var b = new SfBuffer();
		b.addFieldPathAuto(this);
		return b.toString();
	}
	
	/** Whether this field should be assigned a function via = method(type, func) */
	public function needsMethodClosure():Bool {
		if (!parentType.dotStatic) return false;
		if (!Std.is(this, SfClassField)) return false;
		var cf:SfClassField = cast this;
		if (cf.isInst || cf == cf.parentClass.constructor) return false;
		return true;
	}
	
	/**
	 * Returns whether `-D sfgml-print-if` condition can go outside the declaration
	 * (which is so if the static field is non-@:doc and thus shouldn't be referenced)
	 */
	public function needsPrintIfWrap():Bool {
		return !checkDocState(parentType.docState);
	}
}
