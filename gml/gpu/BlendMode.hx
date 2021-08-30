package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("bm") @:snakeCase
extern enum abstract BlendMode(Int) from Int to Int {
	var Zero;
	var One;
	var SrcColor;
	@:noCompletion var SrcColour;
	var InvSrcColor;
	@:noCompletion var InvSrcColour;
	var SrcAlpha;
	var InvSrcAlpha;
	var DestAlpha;
	var InvDestAlpha;
	var DestColor;
	@:noCompletion var DestColour;
	var InvDestColor;
	@:noCompletion var InvDestColour;
	var SrcAlphaSat;
}
