package gml.assets;
import gml.gpu.Texture;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("tileset") extern class Tileset extends Asset {
	public static inline var defValue:Tileset = cast -1;
	
	public static inline function fromIndex(i:Int):Tileset return cast i;
	
	public static inline function isValid(ts:Tileset):Bool {
		// aha, mhm
		return ts.name.charCodeAt(0) != "<".code;
	}
	
	//
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	
	//
	var name(get, never):String;
	private function get_name():String;
	
	//
	var texture(get, never):Texture;
	private function get_texture():Texture;
	
	//
	var uvs(get, never):Array<Float>;
	private function get_uvs():Array<Float>;
}
