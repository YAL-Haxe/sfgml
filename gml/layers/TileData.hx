package gml.layers;

/**
 * ...
 * @author YellowAfterlife
 */
@:using(gml.layers.TileData.TileDataHelpers)
abstract TileData(Int) from Int to Int {
	
}
@:native("tile") @:snakeCase
extern class TileDataHelpers {
	static function getEmpty(td:TileData):Bool;
	static function getIndex(td:TileData):Int;
	static function getFlip(td:TileData):Bool;
	static function getMirror(td:TileData):Bool;
	static function getRotate(td:TileData):Bool;
}