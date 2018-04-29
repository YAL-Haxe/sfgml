package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract CullMode(Int) from Int to Int {
	var NoCulling = 0;
	var Clockwise = 1;
	var CounterClockwise = 2;
	//
	var None = 0;
	var CW = 1;
	var CCW = 2;
}
