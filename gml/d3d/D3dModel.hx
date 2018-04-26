package gml.d3d;
import gml.assets.Texture;
import SfTools.raw;
import gml.ds.Color;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("d3d_model")
extern class D3dModel {
	//
	function new();
	function destroy():Void;
	function clear():Void;
	//
	function draw(x:Float, y:Float, z:Float, tx:Texture):Void;
	//
	@:native("primitive_begin") function beginPrimitive(t:Dynamic):Void;
	inline function beginLineList():Void {
		beginPrimitive(raw("pr_linelist"));
	}
	inline function beginTriangleList():Void {
		beginPrimitive(raw("pr_trianglelist"));
	}
	@:native("primitive_end") function endPrimitive():Void;
	//
	@:native("vertex") function addVertex(x:Float, y:Float, z:Float):Void;
	@:native("vertex_texture") function addVertexTexture(x:Float, y:Float, z:Float,
	tx:Float, ty:Float):Void;
	@:native("vertex_normal_texture") function addVertexNormalTexture(x:Float, y:Float, z:Float,
	nx:Float, ny:Float, nz:Float, tx:Float, ty:Float):Void;
	@:native("vertex_normal_texture_color") function addVertexNormalTextureColor(x:Float, y:Float,
	z:Float, nx:Float, ny:Float, nz:Float, tx:Float, ty:Float, c:Color, a:Float):Void;
	//
	@:native("floor") function addFloor(x1:Float, y1:Float, z1:Float, x2:Float, y2:Float, z2:Float,
	hr:Float, vr:Float):Void;
	
	@:native("cylinder") function addCylinder(x1:Float, y1:Float, z1:Float,
	x2:Float, y2:Float, z2:Float, hr:Float, vr:Float, closed:Bool, steps:Int):Void;
	
	@:native("cone") function addCone(x1:Float, y1:Float, z1:Float, x2:Float, y2:Float, z2:Float,
	hr:Float, vr:Float, closed:Bool, steps:Int):Void;
	
	@:native("ellipsoid") function addEllipsoid(x1:Float, y1:Float, z1:Float,
	x2:Float, y2:Float, z2:Float, hr:Float, vr:Float, steps:Int):Void;
	
	inline function addSphere(x:Float, y:Float, z:Float, r:Float, hr:Float, vr:Float, steps:Int):Void {
		addEllipsoid(x - r, y - r, z + r, x + r, y + r, z - r, hr, vr, steps);
	}
}
