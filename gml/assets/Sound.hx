package gml.assets;

/**
 * ...
 * @author YellowAfterlife
 */
#if (sfgml_next) 
@:native("audio")
#else
@:native("sound")
#end
@:final @:std
extern class Sound extends Asset {
	static inline var defValue:Sound = cast -1;
	
	@:native("exists") static function isValid(q:Sound):Bool;
	
	static inline function fromIndex(i:Int):Sound return cast i;
	//{
	var name(get, never):String;
	private function get_name():String;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//}
}
