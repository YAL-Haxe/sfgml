package gml.net;
import gml.ds.HashTable;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("http") extern class HTTP {
	static inline var defValue:HTTP = cast -1;
	static function get(url:String):HTTP;
	@:native("get_file") static function getFile(url:String, localPath:String):HTTP;
	@:native("post_string") static function postString(url:String, data:String):HTTP;
	static function request(url:String, method:String, headerMap:HashTable<String, String>, body:String):HTTP;
}
