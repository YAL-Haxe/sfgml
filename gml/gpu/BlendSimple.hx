package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("bm") @:snakeCase
extern enum abstract BlendSimple(Int) from Int to Int {
	var Normal;
	var Add;
	var Max;
	@:native("subtract") var Sub;
}
