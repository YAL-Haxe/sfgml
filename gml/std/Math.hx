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
	@:pure static function abs(f:Float):Float;
	@:pure static function min(a:Float, b:Float):Float;
	@:pure static function max(a:Float, b:Float):Float;
	//
	@:pure static function sin(r:Float):Float;
	@:pure static function cos(r:Float):Float;
	@:pure static function tan(r:Float):Float;
	//
	@:pure @:native("arcsin") static function asin(r:Float):Float;
	@:pure @:native("arccos") static function acos(r:Float):Float;
	@:pure @:native("arctan") static function atan(r:Float):Float;
	@:pure @:native("arctan2") static function atan2(y:Float, x:Float):Float;
	//
	@:pure static function exp(f:Float):Float;
	@:pure @:native("ln") static function log(f:Float):Float;
	@:pure @:native("power") static function pow(f:Float, e:Float):Float;
	@:pure static function sqrt(f:Float):Float;
	//
	@:pure static function round(f:Float):Int;
	@:pure static function floor(f:Float):Int;
	@:pure static function ceil(f:Float):Int;
	//
	static inline function random():Float {
		return raw("random")(1);
	}
	//
	@:pure static inline function ffloor(v:Float):Float {
		return floor(v);
	}
	@:pure static inline function fceil(v:Float):Float {
		return ceil(v);
	}
	@:pure static inline function fround(v:Float):Float {
		return raw("round")(v);
	}
	
	#if (sfgml_version && sfgml_version >= "2.2.3")
	@:pure static inline function isNaN(v:Float):Bool return NativeType.isNaN(v);
	@:pure static inline function isFinite(v:Float):Bool return !NativeType.isNonFinite(v);
	static var NaN(default, never):Float;
	@:native("infinity") static var POSITIVE_INFINITY(default, never):Float;
	static var NEGATIVE_INFINITY(get, never):Float;
	@:pure private static inline function get_NEGATIVE_INFINITY():Float {
		return -POSITIVE_INFINITY;
	}
	#else
	static inline function isNaN(v:Float):Bool return MathNaN.isNaN(v);
	static inline function isFinite(v:Float):Bool return MathNaN.isFinite(v);
	//
	static var NaN(get, never):Float;
	@:pure private static inline function get_NaN():Float {
		return MathNaN.not_a_number;
	}
	static var POSITIVE_INFINITY(get, never):Float;
	@:pure private static inline function get_POSITIVE_INFINITY():Float {
		return MathNaN.pos_infinity;
	}
	static var NEGATIVE_INFINITY(get, never):Float;
	@:pure private static inline function get_NEGATIVE_INFINITY():Float {
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
