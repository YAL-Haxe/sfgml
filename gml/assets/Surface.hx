package gml.assets;
import SfTools.raw;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("surface") extern class Surface {
	static inline var none:Surface = cast -1;
	//
	function new(width:Int, height:Int);
	@:native("free") function destroy():Void;
	@:native("exists") static function isValid(sf:Surface):Bool;
	
	//
	var width(get, never):Int;
	private function get_width():Int;
	var height(get, never):Int;
	private function get_height():Int;
	function resize(newWidth:Int, newHeight:Int):Void;
	
	//
	@:native("set_target") function setTarget():Void;
	inline function resetTarget():Void Surface.resetTarget();
	@:native("reset_target") static function resetTarget():Void;
	var texture(get, never):Texture;
	private function get_texture():Texture;
	
	//
	inline function toBackground():Background {
		return raw("background_create_from_surface")(this, 0, 0, width, height, false, false);
	}
	//
}
