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
	
	public function hasMetaType():Bool {
		if (isHidden || nativeGen) return false;
		if (!isUsed) return false;
		if (Std.is(this, SfEnum)) {
			return !(cast this:SfEnum).isFake;
		} else if (Std.is(this, SfClass)) {
			var c:SfClass = cast this;
			return !(c.constructor == null && c.instList.length == 0);
		} else return false;
	}
	
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
	
	public function new(t:BaseType) {
		super(t);
		if (SfCore.sfConfig.modern) {
			#if sfgml_linear
			isStruct = t.meta.has(":gml.struct");
			#else
			isStruct = !isExtern && !t.meta.has(":gml.linear");
			#end
			if (isStruct) dotAccess = true;
		}
	}
}
