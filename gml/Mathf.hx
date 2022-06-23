package gml;
import haxe.extern.Rest;

/**
 * GameMaker-specific built-in math functions.
 * @author YellowAfterlife
 */
@:native("") @:std extern class Mathf {
	@:native("lengthdir_x") static function ldx(len:Float, dir:Float):Float;
	@:native("lengthdir_y") static function ldy(len:Float, dir:Float):Float;
	@:native("point_direction") static function dir2d(x1:Float, y1:Float, x2:Float, y2:Float):Float;
	@:native("point_distance") static function dist2d(x1:Float, y1:Float, x2:Float, y2:Float):Float;
	static function clamp<T:Float>(val:T, min:T, max:T):T;
	static function lerp(vfrom:Float, vto:Float, f:Float):Float;
	static function sign(val:Float):Int;
	static function frac(f:Float):Float;
	static function sqr<T:Float>(val:T):T;
	static function abs<T:Float>(val:T):T;
	static function log10(f:Float):Float;
	static function log2(f:Float):Float;
	static function logn(base:Float, f:Float):Float;
	//
	static function random(max:Float):Float;
	@:native("random_range") static function randomRange(min:Float, max:Float):Float;
	static function irandom(max:Int):Int;
	@:native("irandom_range") static function irandomRange(min:Int, max:Int):Int;
	//
	static function choose<T>(values:Rest<T>):T;
	static function median<T:Float>(values:Rest<T>):T;
	static function min<T:Float>(values:Rest<T>):T;
	static function max<T:Float>(values:Rest<T>):T;
	//
	@:native("degtorad") static function degToRad(deg:Float):Float;
	@:native("radtodeg") static function radToDeg(rad:Float):Float;
	
	@:native("point_in_rectangle") static function pointInRect(x:Float, y:Float, left:Float, top:Float, right:Float, bottom:Float):Bool;
}
