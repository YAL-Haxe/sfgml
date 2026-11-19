package gml.assets;
import gml.particles.*;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("particle") @:final @:std @:snakeCase
extern class ParticleSystemAsset extends gml.assets.Asset {
	public static inline function fromIndex(i:Int):ParticleSystem {
		return cast i;
	}
	
	@:native("exists")
	public static function isValid(ps:ParticleSystemAsset):Bool;
	
	public function getInfo():ParticleSystemInfo;
	
	public inline function create():ParticleSystem {
		return new ParticleSystem(this);
	}
}