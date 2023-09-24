package gml.assets;

/**
 * Note - should remain pure as is also used in macros
 * @author YellowAfterlife
 */
enum abstract AssetType(Int) from Int to Int {
	var AUnknown = -1;
	var AObject = 0;
	var ASprite = 1;
	var ASound = 2;
	var ARoom = 3;
	var ABackground = 4;
	var APath = 5;
	var AScript = 6;
	var AFont = 7;
	var ATimeline = 8;
	var ATiles = 9;
	var AShader = 10;
}
