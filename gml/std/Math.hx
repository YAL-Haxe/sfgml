package ;
import SfTools.raw;
import gml.NativeType;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("") @:std extern class Math {
	@:native("pi") static var PI(default, never):Float;
	//
	static function abs(f:Float):Float;
	static function min(a:Float, b:Float):Float;
	static function max(a:Float, b:Float):Float;
	//
	static function sin(r:Float):Float;
	static function cos(r:Float):Float;
	static function tan(r:Float):Float;
	//
	@:native("arcsin") static function asin(r:Float):Float;
	@:native("arccos") static function acos(r:Float):Float;
	@:native("arctan") static function atan(r:Float):Float;
	@:native("arctan2") static function atan2(y:Float, x:Float):Float;
	//
	static function exp(f:Float):Float;
	@:native("ln") static function log(f:Float):Float;
	@:native("power") static function pow(f:Float, e:Float):Float;
	static function sqrt(f:Float):Float;
	//
	static function round(f:Float):Int;
	static function floor(f:Float):Int;
	static function ceil(f:Float):Int;
	//
	static inline function random():Float {
		return raw("random")(1);
	}
	//
	static inline function fround(v:Float):Float {
		return raw("round")(v);
	}
	#if (sfgml_version && sfgml_version >= "2.2.3")
	static inline function isNaN(v:Float):Bool return NativeType.isNaN(v);
	static inline function isFinite(v:Float):Bool return !NativeType.isNonFinite(v);
	static var NaN(default, never):Float;
	@:native("infinity") static var POSITIVE_INFINITY(default, never):Float;
	static var NEGATIVE_INFINITY(get, never):Float;
	private static inline function get_NEGATIVE_INFINITY():Float {
		return -POSITIVE_INFINITY;
	}
	#else
	static inline function isNaN(v:Float):Bool return MathNaN.isNaN(v);
	static inline function isFinite(v:Float):Bool return MathNaN.isFinite(v);
	//
	static var NaN(get, never):Float;
	private static inline function get_NaN():Float {
		return MathNaN.not_a_number;
	}
	static var POSITIVE_INFINITY(get, never):Float;
	private static inline function get_POSITIVE_INFINITY():Float {
		return MathNaN.pos_infinity;
	}
	static var NEGATIVE_INFINITY(get, never):Float;
	private static inline function get_NEGATIVE_INFINITY():Float {
		return MathNaN.neg_infinity;
	}
	#end
}
@:native("mathnf")
@:std private class MathNaN {
	public static var not_a_number = init(0, 0);
	public static var pos_infinity = init(1, 0);
	public static var neg_infinity = init( -1, 0);
	//
	private static function init(a:Float, b:Float):Float {
		return (a / b);
	}
	public static function isNaN(v:Float):Bool {
		return v != v;
	}
	public static function isFinite(v:Float):Bool {
		// NaN is not equal to NaN
		// inf+1 is equal to inf
		return v == v && v != v + 1;
	}
}
