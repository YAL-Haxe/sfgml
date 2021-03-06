package gml.layers;
import gml.assets.Sprite;
import gml.ds.Color;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("layer_background")
extern class BackgroundElement extends LayerElement {
	//
	public function new(layer:Layer, sprite:Sprite):Void;
	public function destroy():Void;
	
	//
	public var sprite(get, set):Sprite;
	private function get_sprite():Sprite;
	@:native("change") private function raw_sprite(a:Sprite):Void;
	private inline function set_sprite(v:Sprite):Sprite {
		raw_sprite(v);
		return v;
	}
	
	//
	public var index(get, set):Float;
	private function get_index():Float;
	@:native("index") private function raw_index(v:Float):Void;
	private inline function set_index(v:Float):Float {
		raw_index(v);
		return v;
	}
	
	//
	public var speed(get, set):Float;
	private function get_speed():Float;
	@:native("speed") private function raw_speed(v:Float):Void;
	private inline function set_speed(v:Float):Float {
		raw_speed(v);
		return v;
	}
	
	//
	public var visible(get, set):Bool;
	private function get_visible():Bool;
	@:native("visible") private function raw_visible(v:Bool):Void;
	private inline function set_visible(v:Bool):Bool {
		raw_visible(v);
		return v;
	}
	
	//
	public var alpha(get, set):Float;
	private function get_alpha():Float;
	@:native("alpha") private function raw_alpha(a:Float):Void;
	private inline function set_alpha(a:Float):Float {
		raw_alpha(a);
		return a;
	}
	
	//
	public var blend(get, set):Color;
	private function get_blend():Color;
	@:native("blend") private function raw_blend(a:Color):Void;
	private inline function set_blend(c:Color):Color {
		raw_blend(c);
		return c;
	}
	
	//
	public var htiled(get, set):Bool;
	private function get_htiled():Bool;
	@:native("htiled") private function raw_htiled(v:Bool):Void;
	private inline function set_htiled(v:Bool):Bool {
		raw_htiled(v);
		return v;
	}
	
	//
	public var vtiled(get, set):Bool;
	private function get_vtiled():Bool;
	@:native("vtiled") private function raw_vtiled(v:Bool):Void;
	private inline function set_vtiled(v:Bool):Bool {
		raw_vtiled(v);
		return v;
	}
	
	//
	public var xscale(get, set):Float;
	private function get_xscale():Float;
	@:native("xscale") private function raw_xscale(v:Float):Void;
	private inline function set_xscale(v:Float):Float {
		raw_xscale(v);
		return v;
	}
	
	//
	public var yscale(get, set):Float;
	private function get_yscale():Float;
	@:native("yscale") private function raw_yscale(v:Float):Void;
	private inline function set_yscale(v:Float):Float {
		raw_yscale(v);
		return v;
	}
	
	//
	public var stretch(get, set):Bool;
	private function get_stretch():Bool;
	@:native("stretch") private function raw_stretch(v:Bool):Void;
	private inline function set_stretch(v:Bool):Bool {
		raw_stretch(v);
		return v;
	}
}
