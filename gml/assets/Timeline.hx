package gml.assets;

@:native("timeline") @:final @:std
extern class Timeline extends Asset {
	static inline var defValue:PointPath = cast -1;
	//
	@:native("exists") static function isValid(q:Timeline):Bool;
	//
	static inline function fromIndex(i:Int):Timeline return cast i;
	//
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//
	var name(get, never):String;
	private function get_name():String;
}
