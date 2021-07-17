package gml.gpu;
import gml.assets.Sprite;
import gml.ds.Color;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("surface") @:std @:snakeCase
extern class Surface {
	static inline var defValue:Surface = cast -1;
	@:native("exists") static function isValid(q:Surface):Bool;
	
	//
	function new(width:Int, height:Int):Void;
	@:native("create_ext") static function createCanvas(elName:String, width:Int, height:Int):Void;
	@:native("free") function destroy():Void;
	
	//
	var width(get, never):Int;
	private function get_width():Int;
	var height(get, never):Int;
	private function get_height():Int;
	function resize(width:Int, height:Int):Void;
	
	//
	var texture(get, never):Texture;
	private function get_texture():Texture;
	
	/** indicates that this surface is amiss (and is probably best re-made) */
	var isMissing(get, never):Bool;
	private inline function get_isMissing():Bool {
		return !Surface.isValid(this);
	}
	var isValid(get, never):Bool;
	private inline function get_isValid():Bool {
		return Surface.isValid(this);
	}
	
	//
	@:native("getpixel") function getPixel(x:Float, y:Float):Color;
	@:native("getpixel_ext") function getPixelExt(x:Float, y:Float):Int;
	
	//
	function setTarget():Void;
	
	static function setTargetExt(index:Int, surface:Surface):Bool;
	inline function setTargetExt(index:Int):Bool {
		return Surface.setTargetExt(index, this);
	}
	
	static function resetTarget():Void;
	/** purely for convenience - does not use the "calling" surface */
	inline function resetTarget():Void {
		Surface.resetTarget();
	}
	
	//
	@:native("copy") function copyFrom(x:Float, y:Float, source:Surface):Void;
	@:native("copy_part") function copyPartFrom(x:Float, y:Float, source:Surface,
		left:Float, top:Float, width:Float, height:Float):Void;
	
	//
	function save(path:String):Void;
	function savePart(path:String, left:Int, top:Int, width:Int, height:Int):Void;
	
	//
	inline function toSprite(ox:Float, oy:Float):Sprite {
		return Sprite.fromSurface(this, ox, oy);
	}
	
	//
	@:expose("draw_surface") function draw(x:Float, y:Float):Void;
	@:expose("draw_surface_ext") function drawExt(x:Float, y:Float,
		xscale:Float, yscale:Float, angle:Float, color:Color, alpha:Float
	):Void;
	@:expose("draw_surface_part") function drawPart(
		left:Float, top:Float, width:Float, height:Float,
		x:Float, y:Float
	):Void;
	@:expose("draw_surface_part_ext") function drawPartExt(
		left:Float, top:Float, width:Float, height:Float,
		x:Float, y:Float,
		xscale:Float, yscale:Float, color:Color, alpha:Float
	):Void;
	@:expose("draw_surface_general") function drawGeneral(
		left:Float, top:Float, width:Float, height:Float,
		x:Float, y:Float,
		xscale:Float, yscale:Float, angle:Float,
		cTL:Color, cTR:Color, cBL:Color, cBR:Color, alpha:Float
	):Void;
	//
}
