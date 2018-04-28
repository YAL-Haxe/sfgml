package gml.gpu;

/**
 * ...
 * @author YellowAfterlife
 */
@:enum abstract BlendMode(Int) from Int to Int {
	var Zero = 1;
	var One = 2;
	var SrcColor = 3;
	@:noCompletion var SrcColour = 4;
	var InvSrcColor = 4;
	@:noCompletion var InvSrcColour = 4;
	var SrcAlpha = 5;
	var InvSrcAlpha = 6;
	var DestAlpha = 7;
	var InvDestAlpha = 8;
	var DestColor = 9;
	@:noCompletion var DestColour = 9;
	var InvDestColor = 10;
	@:noCompletion var InvDestColour = 10;
	var SrcAlphaSat = 11;
}
