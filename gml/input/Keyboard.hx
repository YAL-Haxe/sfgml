package gml.input;

@:native("keyboard") @:std
extern class Keyboard {
	static function check(keyCode:KeyCode):Bool;
	@:native("check") static function value(keyCode:KeyCode):Int;
	@:native("check_pressed") static function pressed(keyCode:KeyCode):Bool;
	@:native("check_released") static function released(keyCode:KeyCode):Bool;
	static var string:String;
}
