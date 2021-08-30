package gml.ds;
import SfTools.*;

/**
 * Wraps GameMaker's color-related functions and bitwise tricks in a convenient abstract.
 * @author YellowAfterlife
 */
@:docName("int")
abstract Color(Int) from Int to Int {
	public static inline var white = 0xffffff;
	public static inline var black = 0x000000;
	
	public var red(get, set):Int;
	private inline function get_red() return this & 0xff;
	private inline function set_red(i:Int) {
		this = (this & 0xffff00) | (i & 0xff);
		return i;
	}
	
	public var green(get, set):Int;
	private inline function get_green() return (this >> 8) & 0xff;
	private inline function set_green(i:Int) {
		this = (this & 0xff00ff) | ((i & 0xff) << 8);
		return i;
	}
	
	public var blue(get, set):Int;
	private inline function get_blue() return (this >> 16) & 0xff;
	private inline function set_blue(i:Int) {
		this = (this & 0x00ffff) | ((i & 0xff) << 16);
		return i;
	}
	
	public var hue(get, set):Float;
	private inline function get_hue() return raw("color_get_hue")(this);
	private inline function set_hue(v:Float) {
		this = change_hue(this, v);
		return v;
	}
	private static function change_hue(c:Color, v:Float):Color {
		return fromHSV(v, c.saturation, c.value);
	}
	
	public var saturation(get, set):Float;
	private inline function get_saturation() return raw("color_get_saturation")(this);
	private inline function set_saturation(v:Float) {
		this = change_saturation(this, v);
		return v;
	}
	private static function change_saturation(c:Color, v:Float):Color {
		return fromHSV(c.hue, v, c.value);
	}
	
	public var value(get, set):Float;
	private inline function get_value() return raw("color_get_value")(this);
	private inline function set_value(v:Float) {
		this = change_value(this, v);
		return v;
	}
	private static function change_value(c:Color, v:Float):Color {
		return fromHSV(c.hue, c.saturation, v);
	}
	
	public static inline function fromRGB(r:Float, g:Float, b:Float):Color {
		return raw("make_colour_rgb")(r, g, b);
	}
	
	public static inline function fromHSV(h:Float, s:Float, v:Float):Color {
		return raw("make_colour_hsv")(h, s, v);
	}
	
	/** Converts from a RGB constant to GameMaker's BGR */
	public static inline function fromHex(h:Int):Color {
		return ((h & 0xff0000) >> 16) | (h & 0x00ff00) | ((h & 0xff) << 16);
	}
	
	public static inline function merge(c1:Color, c2:Color, f:Float):Color {
		return raw("merge_colour")(c1, c2, f);
	}
}
