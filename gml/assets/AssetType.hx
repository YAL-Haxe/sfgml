package gml.assets;

/**
 * Note - should remain pure as is also used in macros
 * @author YellowAfterlife
 */
@:native("asset") @:snakeCase
extern enum abstract AssetType(Int) from Int to Int {
	@:native("unknown")
	var AUnknown;
	
	@:native("object")
	var AObject;
	
	@:native("sprite")
	var ASprite;
	
	@:native("sound")
	var ASound;
	
	@:native("room")
	var ARoom;
	
	@:native("background")
	var ABackground;
	
	@:native("path")
	var APath;
	
	@:native("script")
	var AScript;
	
	@:native("font")
	var AFont;
	
	@:native("timeline")
	var ATimeline;
	
	@:native("tiles")
	var ATiles;
	
	@:native("shader")
	var AShader;
	
	@:native("animationcurve")
	var AAnimCurve;
	
	@:native("sequence")
	var ASequence;
	
	@:native("particlesystem")
	var AParticleSystem;
}
