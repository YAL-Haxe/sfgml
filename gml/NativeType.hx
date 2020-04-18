package gml;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("") @:snakeCase
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
	
	/** >= 2.3 */
	static function isStruct(v:Dynamic):Bool;
	
	/** >= 2.3 */
	static function isMethod(v:Dynamic):Bool;
	
	/** >= 2.2.3 */
	@:expose("is_nan") static function isNaN(v:Dynamic):Bool;
	
	/** >= 2.2.3 */
	static function isInfinity(v:Dynamic):Bool;
	
	/** Returns whether the value is any of numeric types */
	#if sfgml.modern
	@:expose("is_numeric") static function isNumber(v:Dynamic):Bool;
	#else
	static inline function isNumber(v:Dynamic):Bool {
		return NativeTypeHelper.isNumber(v);
	}
	#end
	
	/** Returns whether the value is numeric and has no fractions */
	static inline function isIntNumber(v:Dynamic):Bool {
		return NativeTypeHelper.isIntNumber(v);
	}
	
	/** Returns whether the value is a NaN or inf */
	static inline function isNonFinite(v:Dynamic):Bool {
		return NativeTypeHelper.isNonFinite(v);
	}
	
	@:expose("typeof") static function typeof(v:Dynamic):String;
	
	@:expose("string") static function toString(v:Dynamic):String;
	@:expose("real") static function toReal(v:Dynamic):Float;
	@:expose("bool") static function toBool(v:Dynamic):Bool;
	@:expose("int64") static function toInt64(v:Dynamic):haxe.Int64;
}
@:noCompletion @:std class NativeTypeHelper {
	public static function isNumber(v:Dynamic) {
		return NativeType.isReal(v)
			|| NativeType.isBool(v)
			|| NativeType.isInt32(v)
			|| NativeType.isInt64(v);
	}
	public static function isIntNumber(value:Dynamic):Bool {
		if (NativeType.isReal(value)) {
			return (value | 0) == value;
		}
		#if sfgml.modern
		return NativeType.isNumber(value);
		#else
		return NativeType.isInt64(value)
			|| NativeType.isInt32(value)
			|| NativeType.isBool(value);
		#end
	}
	public static function isNonFinite(value:Dynamic):Bool {
		return NativeType.isNaN(value) || NativeType.isInfinity(value);
	}
}
