package gml.io;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("") extern class Pointer {
	@:pure @:native("pointer_null") static var nullptr(default, never):Pointer;
	@:pure @:native("pointer_invalid") static var invalid(default, never):Pointer;
	
	@:native("ptr") function new(address:Dynamic);
	@:native("is_ptr") static function isPtr(v:Dynamic):Bool;
	static inline function isNullPtr(v:Dynamic):Bool {
		return v == nullptr;
	}
}
