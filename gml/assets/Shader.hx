package gml.assets;

@:native("shader") @:final @:std
extern class Shader extends Asset {
	static inline var defValue:Sprite = cast -1;
	//
	@:native("exists") static function isValid(q:Shader):Bool;
	//
	static inline function fromIndex(i:Int):Shader return cast i;
	//{
	var name(get, never):String;
	private function get_name():String;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//}
}
