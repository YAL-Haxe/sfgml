package gml.input;

import gml.Lib.raw;

@:native("device_mouse") @:std
extern class Device {
	
	/** Returns whether the given button is currently down. */
	@:native("check_button")
	static function check(index:Int, button:MouseButton):Bool;
	
	/** Returns whether the given button was pressed since the last frame. */
	@:native("check_button_pressed")
	static function pressed(index:Int, button:MouseButton):Bool;
	
	/** Returns whether the given button was released since the last frame. */
	@:native("check_button_released")
	static function released(index:Int, button:MouseButton):Bool;
	
	@:native("x")
	static function roomX(index:Int):Float;
	
	@:native("y")
	static function roomY(index:Int):Float;
	
	@:native("x_to_gui")
	static function guiX(index:Int):Float;
	
	@:native("y_to_gui")
	static function guiY(index:Int):Float;
	
}