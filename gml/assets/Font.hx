package gml.assets;
import gml.gpu.Texture;

@:native("font") @:final @:std
extern class Font extends Asset {
	static inline var defValue:Font = cast -1;
	//
	@:native("exists") static function isValid(q:Font):Bool;
	//
	static inline function fromIndex(i:Int):Font return cast i;
	//{
	var name(get, never):String;
	private function get_name():String;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//}
	var texture(get, never):Texture;
	private function get_texture():Texture;
}
