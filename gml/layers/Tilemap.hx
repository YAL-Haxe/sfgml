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
	@:native("set") private function setImpl(t:TileData, x:Int, y:Int):Void;
	public inline function set(x:Int, y:Int, tile:TileData):Void {
		setImpl(tile, x, y);
	}
}
