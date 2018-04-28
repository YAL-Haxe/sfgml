package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract BlendSimple(Int) from Int to Int {
	var Unknown = -1;
	var Normal = 0;
	var Add = 1;
	var Sub = 2;
}
