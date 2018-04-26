package gml;
import SfTools.raw;
/**
 * Provides access to GameMaker string function subset.
 * Indexes start at 1.
 */
@:native("string") @:final @:std
extern class NativeString {
	
	@:native("byte_at") static function byteAt(str:String, pos:Int):Int;
	
	@:native("byte_length") static function byteLength(str:String):Int;
	
	@:native("char_at") static function charAt(str:String, pos:Int):String;
	
	@:native("ord_at") static function charCodeAt(str:String, pos:Int):Int;
	
	static function copy(str:String, pos:Int, len:Int):String;
	
	static function count(sub:String, str:String):Int;
	
	/// Returns a copy of string with given fragment cut out.
	static function delete(str:String, pos:Int, len:Int):String;
	
	static function digits(str:String):String;
	
	/// Returns a copy of string with fragment inserted at position.
	static function insert(sub:String, str:String, pos:Int):String;
	
	static inline function indexOf(str:String, sub:String):Int {
		return pos(sub, str);
	}
	static function length(str:String):Int;
	
	static function letters(str:String):String;
	
	@:native("lettersdigits") static function lettersDigits(str:String):String;
	
	static function lower(str:String):String;
	
	static function pos(sub:String, str:String):Int;
	
	static inline function contains(str:String, sub:String):Bool {
		return cast pos(sub, str);
	}
	
	static function repeat(str:String, times:Int):String;
	
	static function replace(str:String, sfrom:String, sto:String):String;
	
	@:native("replace_all") static function replaceAll(str:String, sfrom:String, sto:String):String;
	
	static function upper(str:String):String;
	
	static inline function fromCharCode(i:Int):String return raw("chr")(i);
	
	static function format(val:Float, total:Int, decimal:Int):String;
}
