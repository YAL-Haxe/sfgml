package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract VertexFormatUsage(Int) from Int to Int {
	var Position = 1;
	var Color = 2;
	var Normal = 3;
	var TexCoord = 4;
	var BlendWeight = 5;
	var BlendIndices = 6;
	var Tangent = 8;
	var Binormal = 9;
	var Fog = 12;
	var Depth = 13;
	var Sample = 14;
}
