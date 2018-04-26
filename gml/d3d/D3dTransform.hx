package gml.d3d;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("d3d_transform") extern class D3dTransform {
	@:native("stack_push") static function push():Void;
	@:native("stack_pop") static function pop():Void;
	@:native("set_identity") static function identity():Void;
	@:native("add_translation") static function translate(dx:Float, dy:Float, dz:Float):Void;
	@:native("add_scaling") static function scale(mx:Float, my:Float, mz:Float):Void;
	static inline function scaleSame(f:Float):Void scale(f, f, f);
	@:native("add_rotation_x") static function rotateX(f:Float):Void;
	@:native("add_rotation_y") static function rotateY(f:Float):Void;
	@:native("add_rotation_z") static function rotateZ(f:Float):Void;
}
