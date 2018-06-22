package gml.rooms;
import gml.assets.Background;
import gml.ds.Color;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("tile") @:snakeCase
extern class Tile {
	
	//
	@:native("add") public function new(bg:Background,
		left:Float, top:Float, width:Float, height:Float,
		x:Float, y:Float, depth:Float
	):Void;
	
	//
	@:native("delete") public function destroy():Void;
	
	//
	public var background(get, set):Background;
	private function get_background():Background;
	@:native("set_background") private function raw_background(a:Background):Void;
	private inline function set_background(v:Background):Background {
		raw_background(v);
		return v;
	}
	
	//
	public var visible(get, set):Bool;
	private function get_visible():Bool;
	@:native("set_visible") private function raw_visible(a:Bool):Void;
	private inline function set_visible(v:Bool):Bool {
		raw_visible(v);
		return v;
	}
	
	//
	public var blend(get, set):Color;
	private function get_blend():Color;
	@:native("set_blend") private function raw_blend(a:Color):Void;
	private inline function set_blend(v:Color):Color {
		raw_blend(v);
		return v;
	}
	
	//
	public var alpha(get, set):Float;
	private function get_alpha():Float;
	@:native("set_alpha") private function raw_alpha(a:Float):Void;
	private inline function set_alpha(v:Float):Float {
		raw_alpha(v);
		return v;
	}
	
	//
	public var x(get, set):Float;
	private function get_x():Float;
	@:native("set_x") private function raw_x(a:Float):Void;
	private inline function set_x(v:Float):Float {
		raw_x(v);
		return v;
	}
	
	//
	public var y(get, set):Float;
	private function get_y():Float;
	@:native("set_y") private function raw_y(a:Float):Void;
	private inline function set_y(v:Float):Float {
		raw_y(v);
		return v;
	}
	
	//
	public var width(get, set):Float;
	private function get_width():Float;
	@:native("set_width") private function raw_width(a:Float):Void;
	private inline function set_width(v:Float):Float {
		raw_width(v);
		return v;
	}
	
	//
	public var height(get, set):Float;
	private function get_height():Float;
	@:native("set_height") private function raw_height(a:Float):Void;
	private inline function set_height(v:Float):Float {
		raw_height(v);
		return v;
	}
	
	//
	public var left(get, set):Float;
	private function get_left():Float;
	@:native("set_left") private function raw_left(a:Float):Void;
	private inline function set_left(v:Float):Float {
		raw_left(v);
		return v;
	}
	
	//
	public var top(get, set):Float;
	private function get_top():Float;
	@:native("set_top") private function raw_top(a:Float):Void;
	private inline function set_top(v:Float):Float {
		raw_top(v);
		return v;
	}
	
	//
	public var xscale(get, set):Float;
	private function get_xscale():Float;
	@:native("set_xscale") private function raw_xscale(a:Float):Void;
	private inline function set_xscale(v:Float):Float {
		setScale(v, yscale);
		return v;
	}
	
	//
	public var yscale(get, set):Float;
	private function get_yscale():Float;
	@:native("set_yscale") private function raw_yscale(a:Float):Void;
	private inline function set_yscale(v:Float):Float {
		setScale(xscale, v);
		return v;
	}
	
	//
	public function setScale(x:Float, y:Float):Void;
	
	//
	public var depth(get, set):Float;
	private function get_depth():Float;
	@:native("set_depth") private function raw_depth(a:Float):Void;
	private inline function set_depth(v:Float):Float {
		raw_depth(v);
		return v;
	}
}
