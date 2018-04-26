package gml.input;

@:native("gamepad") @:std
extern class Gamepad {
	
	/** The number of gamepad "slots" */
	@:native("device_count")
	public static var deviceCount(get, never):Int;
	@:native("get_device_count")
	private static function get_deviceCount():Int;
	
	/** Returns whether the given gamepad is connected */
	@:native("is_connected")
	static function isConnected(index:Int):Bool;
	
	@:native("button_check")
	static function check(index:Int, button:GamepadButton):Bool;
	
	@:native("button_check_pressed")
	static function pressed(index:Int, button:GamepadButton):Bool;
	
	@:native("button_check_released")
	static function released(index:Int, button:GamepadButton):Bool;
	
	@:native("axis_value")
	static function axis(index:Int, axis:GamepadAxis):Float;
}
