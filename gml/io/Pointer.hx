package gml.io;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("") extern class Pointer {
	@:native("ptr") public function new(address:Dynamic);
	@:native("is_ptr") public static function isPtr(v:Dynamic):Bool;
}
