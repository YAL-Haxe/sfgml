package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract VertexFormatType(Int) from Int to Int {
	var Float1 = 1;
	var Float2 = 2;
	var Float3 = 3;
	var Float4 = 4;
	var Color = 5;
	var UByte4 = 6;
}
