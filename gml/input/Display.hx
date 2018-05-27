package gml.input;
import SfTools.raw;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("display") @:snakeCase
extern class Display {
	//
	static var width(get, never):Int;
	private static function get_width():Int;
	//
	static var height(get, never):Int;
	private static function get_height():Int;
	//
	static function reset(aa:Int, vsync:Bool):Int;
	static var aaFlags(get, never):Int;
	private static inline function get_aaFlags():Int return raw("display_aa");
	//{
	static var mouseX(get, never):Float;
	@:native("mouse_get_x") private static function get_mouseX():Float;
	//
	static var mouseY(get, never):Float;
	@:native("mouse_get_y") private static function get_mouseY():Float;
	//
	@:native("mouse_set") static function setMouse(x:Float, y:Float):Void;
	//}
	
	//{
	static var guiWidth(get, never):Float;
	private static function get_guiWidth():Float;
	
	static var guiHeight(get, never):Float;
	private static function get_guiHeight():Float;
	//}
}
