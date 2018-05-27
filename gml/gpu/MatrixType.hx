package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract MatrixType(Int) {
	var View = 0;
	var Projection = 1;
	var World = 2;
}
