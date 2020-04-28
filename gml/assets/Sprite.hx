package gml.assets;
import gml.ds.Color;
import gml.gpu.Surface;
import gml.gpu.Texture;

@:native("sprite") @:final @:std @:snakeCase
extern class Sprite extends Asset {
	static inline var defValue:Sprite = cast -1;
	//
	@:native("exists") static function isValid(q:Sprite):Bool;
	//
	static inline function fromIndex(i:Int):Sprite return cast i;
	
	//{ ctr
	@:native("add") private static function loadRaw(
		path:String, frames:Int, rb:Bool, smooth:Bool, x:Float, y:Float
	):Sprite;
	public static inline function load(path:String, frames:Int, x:Float, y:Float):Sprite {
		return loadRaw(path, frames, false, false, x, y);
	}
	
	@:native("create_from_surface") private static function fromSurfaceRaw(
		sf:Surface, x:Float, y:Float, w:Float, h:Float, rb:Bool, smooth:Bool, ox:Float, oy:Float
	):Sprite;
	public static inline function fromSurfacePart(sf:Surface,
		rx:Float, ry:Float, rw:Float, rh:Float, ox:Float, oy:Float
	):Sprite {
		return fromSurfaceRaw(sf, rx, ry, rw, rh, false, false, ox, oy);
	}
	public static inline function fromSurface(sf:Surface, ox:Float, oy:Float):Sprite {
		return fromSurfaceRaw(sf, 0, 0, sf.width, sf.height, false, false, ox, oy);
	}
	
	@:native("add_from_surface") private function addSurfaceRaw(
		sf:Surface, rx:Float, ry:Float, rw:Float, rh:Float, rb:Bool, smooth:Bool
	):Void;
	public inline function addSurfacePart(sf:Surface, x:Float, y:Float, w:Float, h:Float):Void {
		addSurfaceRaw(sf, x, y, w, h, false, false);
	}
	public inline function addSurface(sf:Surface):Void {
		addSurfaceRaw(sf, 0, 0, sf.width, sf.height, false, false);
	}
	
	/** */
	public function merge(spr:Sprite):Void;
	
	public function assign(copyFrom:Sprite):Void;
	@:native("delete") public function destroy():Void;
	//}
	
	//{ general
	var name(get, never):String;
	private function get_name():String;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	
	var width(get, never):Int;
	private function get_width():Int;
	
	var height(get, never):Int;
	private function get_height():Int;
	
	var offsetX(get, never):Float;
	@:native("get_xoffset") private function get_offsetX():Float;
	
	var offsetY(get, never):Float;
	@:native("get_yoffset") private function get_offsetY():Float;
	
	var frames(get, never):Int;
	@:native("get_number") private function get_frames():Int;
	//}
	
	//{ bbox
	var bboxLeft(get, never):Int;
	@:native("get_bbox_left") private function get_bboxLeft():Int;
	
	var bboxTop(get, never):Int;
	@:native("get_bbox_top") private function get_bboxTop():Int;
	
	var bboxRight(get, never):Int;
	@:native("get_bbox_right") private function get_bboxRight():Int;
	
	var bboxBottom(get, never):Int;
	@:native("get_bbox_bottom") private function get_bboxBottom():Int;
	
	@:native("collision_mask") public function setCollisionMask(sepMasks:Bool,
		bboxMode:Int, bboxLeft:Float, bboxTop:Float, bboxRight:Float, bboxBottom:Float,
		maskKind:Int, tolerance:Float
	):Void;
	//}
	
	//{ texture
	var textures(get, never):SpriteTextures;
	private inline function get_textures():SpriteTextures {
		return this;
	}
	@:native("get_texture") public function textureAt(subimg:Int):Texture;
	//}
	
	//{
	@:expose("draw_sprite") function draw(subimg:Float, x:Float, y:Float):Void;
	@:expose("draw_sprite_ext") function drawExt(subimg:Float, x:Float, y:Float,
		xscale:Float, yscale:Float, angle:Float, color:Color, alpha:Float):Void;
	//
	@:expose("draw_sprite_part") function drawPart(subimg:Float, left:Float, top:Float,
		width:Float, height:Float, x:Float, y:Float):Void;
	@:expose("draw_sprite_part_ext") function drawPartExt(subimg:Float, left:Float, top:Float,
		width:Float, height:Float, x:Float, y:Float, color:Color, alpha:Float):Void;
	//
	@:expose("draw_sprite_general") function drawGeneral(subimg:Float,
		left:Float, top:Float, width:Float, height:Float,
		x:Float, y:Float, xscale:Float, yscale:Float, angle:Float,
		c1:Color, c2:Color, c3:Color, c4:Color, alpha:Float):Void;
	//
	@:expose("draw_sprite_stretched") function drawStretched(subimg:Float,
		x:Float, y:Float, w:Float, h:Float):Void;
	@:expose("draw_sprite_stretched_ext") function drawStretchedExt(subimg:Float,
		x:Float, y:Float, w:Float, h:Float, color:Color, alpha:Float):Void;
	//
	@:expose("draw_sprite_tiled") function drawTiled(subimg:Float, x:Float, y:Float):Void;
	@:expose("draw_sprite_tiled_ext") function drawTiledExt(subimg:Float, x:Float, y:Float,
		xscale:Float, yscale:Float, color:Color, alpha:Float):Void;
	//
	@:expose("draw_sprite_pos") function drawQuad(subimg:Float, x1:Float, y1:Float,
		x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float, alpha:Float):Void;
	//}
}

abstract SpriteTextures(Sprite) from Sprite {
	@:arrayAccess private inline function get(i:Int):Texture {
		return this.textureAt(i);
	}
}
