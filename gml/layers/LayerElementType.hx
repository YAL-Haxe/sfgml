package gml.layers;

/**
 * ...
 * @author YellowAfterlife
 */
enum abstract LayerElementType(Int) {
	var LUnknown = 0;
	var LBackground = 1;
	var LInstance = 2;
	var LTilemap = 5;
	var LParticleSystem = 6;
}
