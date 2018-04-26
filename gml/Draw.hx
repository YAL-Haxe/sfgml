package gml;
import gml.assets.*;
import gml.draw.BlendMode;
import gml.ds.Color;

@:std @:native("draw")
extern class Draw {
	//
	static var color(get, set):Color;
	private static function get_color():Color;
	private static function set_color(c:Color):Color;
	
	//
	static var alpha(get, set):Float;
	private static function get_alpha():Float;
	private static function set_alpha(f:Float):Float;
	
	//
	static function clear(c:Color):Void;
	@:native("clear_alpha") static function clearAlpha(c:Color, a:Float):Void;
	
	//{ shape
	static function circle(x:Float, y:Float, r:Float, outline:Bool):Void;
	//}
	
	//{ sprite
	static function sprite(spr:Sprite, subimg:Float, x:Float, y:Float):Void;
	
	@:native("sprite_ext")
	static function spriteExt(spr:Sprite, subimg:Float, x:Float, y:Float, scaleX:Float, scaleY:Float, angle:Float, color:Color, alpha:Float):Void;
	//}
	
	#if !sfgml_next
	static function background(bck:Background, x:Float, y:Float):Void;
	
	@:native("background_ext")
	static function backgroundExt(bck:Background, x:Float, y:Float, scaleX:Float, scaleY:Float, angle:Float, color:Color, alpha:Float):Void;
	
	@:native("background_part")
	static function backgroundPart(bck:Background, left:Float, top:Float, width:Float, height:Float, x:Float, y:Float):Void;
	
	@:native("background_part_ext")
	static function backgroundPartExt(bck:Background, left:Float, top:Float, width:Float, height:Float, x:Float, y:Float, xscale:Float, yscale:Float, color:Int, alpha:Float):Void;
	#end
	
	//{
	static function surface(sf:Surface, x:Float, y:Float):Void;
	
	@:native("surface_ext")
	static function surfaceExt(sf:Surface, x:Float, y:Float, sx:Float, sy:Float, f:Float, c:Color, a:Float):Void;
	//}
	
	@:native("set_blend_mode") static function setBlendMode(mode:BlendMode):Void;
}
