package gml;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("") @:snakeCase
extern class NativeType {
	static function isArray(v:Dynamic):Bool;
	static function isBool(v:Dynamic):Bool;
	static function isInt32(v:Dynamic):Bool;
	static function isInt64(v:Dynamic):Bool;
	static function isPtr(v:Dynamic):Bool;
	static function isReal(v:Dynamic):Bool;
	static function isString(v:Dynamic):Bool;
	static function isUndefined(v:Dynamic):Bool;
	static function isVec3(v:Dynamic):Bool;
	static function isVec4(v:Dynamic):Bool;
	/* Returns whether the value is any of numeric types */
	static inline function isNumber(v:Dynamic):Bool {
		return NativeTypeHelper.isNumber(v);
	}
	@:expose("typeof") static function typeof(v:Dynamic):String;
}
@:std @:native("is_helper") private class NativeTypeHelper {
	public static function isNumber(v:Dynamic) {
		return NativeType.isReal(v)
			|| NativeType.isBool(v)
			|| NativeType.isInt32(v)
			|| NativeType.isInt64(v);
	}
}
