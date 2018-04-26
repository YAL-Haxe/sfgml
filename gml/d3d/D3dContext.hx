package gml.d3d;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("d3d")
extern class D3dContext {
	@:native("start") static function enable():Void;
	@:native("end") static function disable():Void;
	//
	@:native("set_culling") static function setCulling(enable:Bool):Void;
	@:native("set_hidden") static function setHidden(enable:Bool):Void;
	//
	@:native("set_projection")
	static function setProjection(x1:Float, y1:Float, z1:Float,
	x2:Float, y2:Float, z2:Float, xup:Float, yup:Float, zup:Float):Void;
	//
	@:native("set_projection_ext")
	static function setProjectionExt(x1:Float, y1:Float, z1:Float,
	x2:Float, y2:Float, z2:Float, xup:Float, yup:Float, zup:Float,
	fov:Float, aspect:Float, znear:Float, zfar:Float):Void;
	//
	@:native("set_projection_ortho")
	static function setProjectionOrtho(x:Float, y:Float, w:Float, h:Float, angle:Float):Void;
	//
}
