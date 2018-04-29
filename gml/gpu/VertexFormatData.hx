package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:nativeGen
enum VertexFormatData {
	Color;
	Pos2d;
	Pos3d;
	TexCoord;
	Normal;
	Custom(type:VertexFormatType, usage:VertexFormatUsage);
}
