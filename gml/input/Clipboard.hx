package gml.input;

/**
 * ...
 * @author YellowAfterlife
 */
@:snakeCase @:std @:native("clipboard")
extern class Clipboard {
	public static function getText():String;
	public static function setText(s:String):Void;
	public static function hasText():Bool;
}
