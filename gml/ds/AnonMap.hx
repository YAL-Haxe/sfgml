package gml.ds;
import SfTools.raw;

/**
 * By tagging typedefs as `@:dsMap`, you can conveniently map out JSON externs.
 * This class further aids with this process.
 * @author YellowAfterlife
 */
extern class AnonMap {
	
	@:noUsing @:expose("json_decode") public static function parse<T:{}>(json:String):T;
	
	@:expose("ds_map_destroy") public static function destroy<T:{}>(ds_typedef:T):Void;
	
	@:expose("json_encode") public static function encode<T:{}>(ds_typedef:T):String;
	
}
