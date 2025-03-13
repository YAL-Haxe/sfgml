package gml.assets;
import gml.assets.AssetType;

/**
 * ...
 * @author YellowAfterlife
 */
@:snakeCase @:native("asset")
extern class Asset {
	static inline var defValue:Asset = cast -1;
	
	@:native("get_index")
	static function find<T:Asset>(name:String):T;
	
	@:native("get_type")
	static function type(name:String):AssetType;
	
	static function getIDs<T:Asset>(type:AssetType):Array<T>;
	
	static inline function fromIndex<T:Asset>(index:Int):T {
		return cast index;
	}
}
