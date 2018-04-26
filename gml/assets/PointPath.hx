package gml.assets;

@:native("path") @:final @:std
extern class PointPath extends Asset {
	static inline var defValue:PointPath = cast -1;
	//
	@:native("exists") static function isValid(q:PointPath):Bool;
	//
	static inline function fromIndex(i:Int):PointPath return cast i;
	//
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//
	var name(get, never):String;
	private function get_name():String;
}
