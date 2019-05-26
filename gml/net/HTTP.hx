package gml.net;
import gml.ds.HashTable;
import haxe.extern.EitherType;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("http") @:snakeCase
extern class HTTP {
	static inline var defValue:HTTP = cast -1;
	static function get(url:String):HTTP;
	@:native("get_file") static function getFile(url:String, localPath:String):HTTP;
	@:native("post_string") static function postString(url:String, data:String):HTTP;
	static function request(url:String, method:String, headerMap:HashTable<String, String>, body:EitherType<String, gml.io.Buffer>):HTTP;
}
