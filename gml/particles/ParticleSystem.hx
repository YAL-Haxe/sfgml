package gml.particles;
import gml.assets.ParticleSystemAsset;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("part_system") @:final @:std @:snakeCase
extern class ParticleSystem {
	public static inline function fromIndex(i:Int):ParticleSystem {
		return cast i;
	}
	
	@:native("exists")
	public static function isValid(ps:ParticleSystem):Bool;
	
	public function new(?config:ParticleSystemAsset);
	
	public function getInfo():ParticleSystemInfo;
}
