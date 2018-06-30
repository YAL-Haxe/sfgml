package gml.physics;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("physics_world") @:snakeCase
extern class PhyWorld {
	public static function create(px2m:Float):Void;
	@:native("gravity") public static function setGravity(x:Float, y:Float):Void;
}
