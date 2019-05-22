package gml.sys;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:snakeCase
extern class Dialog {
	@:expose("show_message") static function showMessage(text:String):Void;
	@:expose("get_string") static function getString(prompt:String, defval:String):String;
	@:expose("get_integer") static function getInteger(prompt:String, defval:Int):Null<Int>;
}
