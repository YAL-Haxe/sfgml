package gml.assets;
import gml.Lib.raw;
/**
 * ...
 * @author YellowAfterlife
 */
@:native("room") @:final
extern class Room extends Asset {
	@:native("exists") static function isValid(q:Room):Bool;
	
	static inline function fromIndex(i:Int):Room return cast i;
	//
	var name(get, null):String;
	private function get_name():String;
	//{
	var next(get, never):Room;
	@:native("next") function get_next():Room;
	var previous(get, never):Room;
	@:native("previous") function get_previous():Room;
	//}
}
