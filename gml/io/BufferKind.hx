package gml.io;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract BufferKind(Int) from Int to Int {
	var Fixed = 0;
	var Grow = 1;
	var Wrap = 2;
	var Fast = 3;
}
