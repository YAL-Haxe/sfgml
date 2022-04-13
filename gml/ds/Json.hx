package gml.ds;

/**
 * NB! Only available in GMS2.3+
 * @author YellowAfterlife
 */
@:native("json") extern class Json {
	static function parse(str:String):Dynamic;
	static function stringify(val:Dynamic):String;
}