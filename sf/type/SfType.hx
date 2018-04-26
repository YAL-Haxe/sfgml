package sf.type;

/**
 * ...
 * @author YellowAfterlife
 */
class SfType extends SfTypeImpl {
	public var index:Int = -1;
	public static var indexes:Int = 0;
	/** Whether the type is referenced anywhere */
	public var isUsed:Bool = false;
}
