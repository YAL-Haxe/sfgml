package gml.input;

import gml.Lib.raw;

@:native("mouse") @:std
extern class Mouse {
	
	/** Returns whether the given button is currently down. */
	@:native("check_button") static function check(button:MouseButton):Bool;
	
	/** Returns whether the given button was pressed since the last frame. */
	@:native("check_button_pressed") static function pressed(button:MouseButton):Bool;
	
	/** Returns whether the given button was released since the last frame. */
	@:native("check_button_released") static function released(button:MouseButton):Bool;
	
	@:native("wheel_up") static function wheelUp():Int;
	@:native("wheel_down") static function wheelDown():Int;
	static var wheelDelta(get, never):Int;
	private static inline function get_wheelDelta():Int {
		return wheelUp() - wheelDown();
	}
	
	/** Room-space cursor' X */
	@:native("x") static var roomX(default, never):Float;
	
	/** Room-space cursor' Y */
	@:native("y") static var roomY(default, never):Float;
	
	static var guiX(get, never):Float;
	private static inline function get_guiX():Float {
		return Device.guiX(0);
	}
	
	static var guiY(get, never):Float;
	private static inline function get_guiY():Float {
		return Device.guiY(0);
	}
}