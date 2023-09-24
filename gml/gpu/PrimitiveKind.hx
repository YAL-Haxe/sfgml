package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
enum abstract PrimitiveKind(Int) from Int to Int {
	var PointList = 1;
	var LineList = 2;
	var LineStrip = 3;
	var TriangleList = 4;
	var TriangleStrip = 5;
	/** as per doc, may not work as expected */
	var TriangleFan = 6;
}
