package gml.input;

@:native("keyboard") @:std
extern class Keyboard {
	static function check(keyCode:KeyCode):Bool;
	@:native("check") static function value(keyCode:KeyCode):Int;
	@:native("check_pressed") static function pressed(keyCode:KeyCode):Bool;
	@:native("check_released") static function released(keyCode:KeyCode):Bool;
	@:native("check_direct") static function rawValue(keyCode:KeyCode):Int;
	@:native("key_press") static function simPress(keyCode:KeyCode):Void;
	@:native("key_release") static function simRelease(keyCode:KeyCode):Void;
	static var string:String;
}
