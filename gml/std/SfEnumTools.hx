package;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("haxe_enum_tools")
class SfEnumTools {
	public static inline function getParameter(q:EnumValue, i:Int):Dynamic {
		return SfGmlEnumValue.fromEnumValue(q).get(i + 1);
	}
	public static inline function getParameterCount(q:EnumValue):Int {
		return SfGmlEnumValue.fromEnumValue(q).length - 1;
	}
	public static inline function setParameter(q:EnumValue, i:Int, v:Dynamic):Void {
		return SfGmlEnumValue.fromEnumValue(q).set(i + 1, v);
	}
	@:native("set")
	public static function setTo<T:EnumValue>(q:T, v:T):Void {
		var qx = SfGmlEnumValue.fromEnumValue(q);
		var vx = SfGmlEnumValue.fromEnumValue(v);
		#if (debug)
		gml.NativeArray.set2d(qx, 1, 1, gml.NativeArray.get2d(vx, 1, 1));
		#end
		for (i in 0 ... vx.length) {
			qx.set(i, vx.get(i));
		}
	}
}
@:std private abstract SfGmlEnumValue(Array<Dynamic>) to Array<Dynamic> from Array<Dynamic> {
	@:from public static inline function fromEnumValue(v:EnumValue):SfGmlEnumValue return cast v;
	//
	public var length(get, never):Int;
	private inline function get_length():Int return this.length;
	//
	public inline function get(i:Int):Dynamic return this[i];
	public inline function set(i:Int, v:Dynamic):Void this[i] = v;
}
