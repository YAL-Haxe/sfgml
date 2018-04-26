package gml.input;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("window") extern class Window {
	//
	static var width(get, never):Int;
	private static function get_width():Int;
	//
	static var height(get, never):Int;
	private static function get_height():Int;
	@:native("set_size") public static function resize(w:Int, h:Int):Void;
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
	@:native("get_cursor") private static function get_mouseCursor():Dynamic;
	@:native("set_cursor") private static function setMouseCursor(v:Dynamic):Void;
	private static inline function set_mouseCursor(v:Dynamic):Dynamic {
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
@:native("cr") extern enum WindowCursor {
	none;
	arrow;
	cross;
	beam;
	@:native("size_nesw") sizeNESW;
	@:native("size_ns") sizeNS;
	@:native("size_nwse") sizeNWSE;
	@:native("size_we") sizeWE;
	uparrow;
	hourglass;
	drag;
	appstart;
	handpoint;
	@:native("size_all") sizeAll;
}
