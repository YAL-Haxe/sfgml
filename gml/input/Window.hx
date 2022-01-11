package gml.input;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("window") extern class Window {
	static var x(get, never):Int;
	private static function get_x():Int;
	//
	static var y(get, never):Int;
	private static function get_y():Int;
	//
	static var width(get, never):Int;
	private static function get_width():Int;
	//
	static var height(get, never):Int;
	private static function get_height():Int;
	@:native("set_position") public static function move(x:Int, y:Int):Void;
	@:native("set_size") public static function resize(w:Int, h:Int):Void;
	@:native("set_rectangle") public static function setRect(x:Int, y:Int, w:Int, h:Int):Void;
	//
	static var hasFocus(get, never):Bool;
	@:native("has_focus") private static function get_hasFocus():Bool;
	//
	static var mouseX(get, never):Float;
	@:native("mouse_get_x") private static function get_mouseX():Float;
	//
	static var mouseY(get, never):Float;
	@:native("mouse_get_y") private static function get_mouseY():Float;
	//
	@:native("mouse_set") static function setMouse(x:Float, y:Float):Void;
	//
	static var mouseCursor(get, set):Dynamic;
	@:native("get_cursor") private static function get_mouseCursor():WindowCursor;
	@:native("set_cursor") private static function setMouseCursor(v:WindowCursor):Void;
	private static inline function set_mouseCursor(v:WindowCursor):Dynamic {
		setMouseCursor(v);
		return v;
	}
	//
	static var fullscreen(get, set):Bool;
	private static function get_fullscreen():Bool;
	@:native("set_fullscreen") private static function setFullscreen(v:Bool):Void;
	private static inline function set_fullscreen(v:Bool):Bool {
		setFullscreen(v);
		return v;
	}
}
@:native("cr") extern enum abstract WindowCursor(Int) {
	var none;
	var arrow;
	var cross;
	var beam;
	@:native("size_nesw") var sizeNESW;
	@:native("size_ns") var sizeNS;
	@:native("size_nwse") var sizeNWSE;
	@:native("size_we") var sizeWE;
	var uparrow;
	var hourglass;
	var drag;
	var appstart;
	var handpoint;
	@:native("size_all") var sizeAll;
}
