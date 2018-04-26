package gml.assets;
import gml.Lib.raw;
/**
 * ...
 * @author YellowAfterlife
 */
@:native("background") @:final @:std
extern class Background extends Asset {
	static inline var defValue:Background = cast -1;
	
	//
	@:native("exists") static function isValid(q:Background):Bool;
	
	//
	static inline function fromIndex(i:Int):Background return cast i;
	
	//{
	/// Background name (as set in the IDE)
	var name(get, never):String;
	private function get_name():String;
	
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	
	var width(get, never):Int;
	private function get_width():Int;
	
	var height(get, never):Int;
	private function get_height():Int;
	
	var texture(get, never):Texture;
	private function get_texture():Texture;
	//}
	
	//
	function new(width:Int, height:Int, color:Int);
	
	//
	@:constructor @:native("create_colour")
	static function create(width:Int, height:Int, color:Int):Background;
	
	//
	@:native("delete") function destroy():Void;
	
	//
	static function exists(bck:Background):Bool;
	
	static inline function find(name:String):Background {
		return cast Asset.find(name);
	}
	
	function duplicate():Background;
	
	@:native("assign") function copyFrom(src:Background):Void;
	
	
}
