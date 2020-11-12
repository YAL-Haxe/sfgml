package sf.type;
import haxe.macro.Type;
import sf.SfCore.*;
using sf.type.expr.SfExprTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfClassField extends SfClassFieldImpl {
	public var index:Int = -1;
	
	/** Whether `this` is used in the call (included as argument or otherwise) */
	public var callNeedsThis:Bool = false;
	public function new(parent:SfType, field:ClassField, inst:Bool) {
		super(parent, field, inst);
		if (inst) switch (field.kind) {
			case FMethod(_): callNeedsThis = true;
			default:
		}
	}
	
	public function getArgDoc(parState:Int):String {
		if (checkDocState(parState)) {
			var sfb = new SfBuffer();
			SfArgVars.doc(sfb, this, 4);
			return sfb.toString();
		} else return null;
	}
	
	/** Whether `this` prefix-argument should be included. */
	public function needsThisArg():Bool {
		if (isStructField) return false;
		var fdc = parentClass;
		if (fdc != null) {
			if (isInst && this == fdc.constructor && fdc.needsSeparateNewFunc()) {
				return true;
			}
		}
		return isInst;
	}
	
	/** Whether GML `self` is used as `this` */
	public inline function isSelfCall():Bool {
		return (isInst || this == parentClass.constructor) && parentClass.isStruct;
	}
	
	/** Whether this field will have a function generated for method body */
	public inline function needsFunction():Bool {
		return !isHidden && isCallable && expr != null;
	}
	
	/** Returns code for a getter macro, provided that this is a getter */
	public function getGetterMacro():String {
		// just to be sure (and quick-cut inline expressions):
		switch (kind) {
			case FVar(AccInline, AccNo | AccNever): {
				switch (expr.def) {
					case SfConst(_): return sprintf("%x", expr);
					default: return sprintf("(%x)", expr);
				}
			}
			case FVar(AccCall, AccNo | AccNever): {};
			default: return null;
		}
		// no dot statics:
		if (parentClass.dotStatic) {
			classField.pos.warningAt('Can\'t print a macro for $realName in a dot-static class.');
			return null;
		}
		// lookup getter:
		var getterName = "get_" + realName;
		var getter = parentClass.realMap[getterName];
		if (getter == null) {
			classField.pos.warningAt('Can\'t find the getter $getterName to expose for $realName');
			return null;
		}
		//
		switch ([getter.kind, getter.expr.def]) {
			case [FMethod(MethInline), SfReturn(true, v)]: {
				// if method is inline and single-line, we'll use that as the macro value
				return sprintf("(%x)", v);
			};
			default: {
				return sprintf("%(field_auto)()", getter);
			};
		}
	}
}
