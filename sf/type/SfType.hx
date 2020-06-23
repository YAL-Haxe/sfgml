package sf.type;
import haxe.macro.Type.BaseType;

/**
 * ...
 * @author YellowAfterlife
 */
class SfType extends SfTypeImpl {
	
	/** Type index */
	public var index:Int = -1;
	
	/** Total type indexes */
	public static var indexes:Int = 0;
	
	/** Whether the type is referenced anywhere */
	public var isUsed:Bool = false;
	
	/** Whether the type is direcently referenced and we need to generate a mt_ for it */
	public var hasTypeExpr:Bool = false;
	
	public function hasMetaType():Bool {
		if (hasTypeExpr) return true;
		if (isHidden || nativeGen) return false;
		if (!isUsed) return false;
		if (Std.is(this, SfEnum)) {
			return !(cast this:SfEnum).isFake;
		} else if (Std.is(this, SfClass)) {
			var c:SfClass = cast this;
			return !(c.constructor == null && c.instList.length == 0);
		} else return false;
	}
	
	/** Classes marked `@:std` get unprefixed variable access. */
	public var isStd:Bool;
	
	/**
	 * Uses 2.3 structs as an underlying type.
	 * If false, instance functions shall take "this" as the first argument,
	 * and 
	 */
	public var isStruct:Bool = false;
	
	/**
	 * Whether to do q.<instField> instead of q[<instField index>].
	 * Types with isStruct=true will have dotAccess=true, but not necessarily
	 * the opposite - for example, GameMaker instances ( @see gml.Instance)
	 * use dotAccess, but are not structs, thus are passed to functions.
	 */
	public var dotAccess:Bool = false;
	
	/**
	 * Whether dotAccess should apply to static fields.
	 * This is controlled via -D sfgml_dot_static in 2.3, default is true.
	 */
	public var dotStatic:Bool = false;
	
	public function new(t:BaseType) {
		super(t);
		isStd = t.meta.has(":std");
		if (SfCore.sfConfig.modern) {
			var preferLinear = isStd;
			#if sfgml_linear
			preferLinear = true;
			#end
			if (preferLinear) {
				isStruct = t.meta.has(":gml.struct");
			} else {
				isStruct = !isExtern && !t.meta.has(":gml.linear");
			}
			if (isStruct) {
				dotAccess = true;
				if (SfCore.sfConfig.dotStatic) {
					if (!meta.has(":gml.flat_static")) dotStatic = true;
				} else {
					if (meta.has(":gml.dot_static")) dotStatic = true;
				}
			}
		}
	}
}
