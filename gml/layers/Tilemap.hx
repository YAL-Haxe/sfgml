package gml.layers;
import gml.assets.Tileset;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("tilemap") @:snakeCase
extern class Tilemap extends LayerElement {
	//
	@:expose("layer_tilemap_create") public function new(
		layer:LayerID, x:Float, y:Float, ts:Tileset, cols:Int, rows:Int
	):Void;
	@:expose("layer_tilemap_destroy") public function destroy():Void;
	//
	public function get(x:Int, y:Int):TileData;
	@:native("set") private function __set(t:TileData, x:Int, y:Int):Void;
	public inline function set(x:Int, y:Int, tile:TileData):Void {
		__set(tile, x, y);
	}
	
	@:native("set_at_pixel") private function __setAtPixel(t:TileData, x:Float, y:Float):Void;
	public inline function setAtPixel(x:Float, y:Float, tile:TileData):Void {
		__setAtPixel(tile, x, y);
	}
	
	public var x(get, set):Float;
	private function get_x():Float;
	private inline function set_x(val:Float):Float {
		__x(val); return val;
	}
	@:native("x") private function __x(val:Float):Void;
	
	public var y(get, set):Float;
	private function get_y():Float;
	private inline function set_y(val:Float):Float {
		__y(val); return val;
	}
	@:native("y") private function __y(val:Float):Void;
	
	public var tileWidth(get, never):Int;
	private function get_tileWidth():Int;
	
	public var tileHeight(get, never):Int;
	private function get_tileHeight():Int;
}
