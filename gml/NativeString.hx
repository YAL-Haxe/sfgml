package gml;
import SfTools.raw;
/**
 * Provides access to GameMaker string function subset.
 * Indexes start at 1.
 */
@:native("string") @:final @:std @:snakeCase
extern class NativeString {
	
	static function byteAt(str:String, pos:Int):Int;
	
	static function byteLength(str:String):Int;
	
	static function charAt(str:String, pos:Int):String;
	
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
	
	/** Filters out any characters outside of [a-zA-Z0-9] group */
	@:native("lettersdigits") static function lettersDigits(str:String):String;
	
	static function lower(str:String):String;
	
	static function pos(sub:String, str:String):Int;
	
	/** >=2.3 */
	static function posExt(sub:String, str:String, start:Int):Int;
	
	/** >=2.3 */
	static function lastPos(sub:String, str:String):Int;
	
	/** >=2.3 */
	static function lastPosExt(sub:String, str:String, start:Int):Int;
	
	static inline function contains(str:String, sub:String):Bool {
		return pos(sub, str) != 0;
	}
	
	static function repeat(str:String, times:Int):String;
	
	static function replace(str:String, sfrom:String, sto:String):String;
	
	@:native("replace_all") static function replaceAll(str:String, sfrom:String, sto:String):String;
	
	static function upper(str:String):String;
	
	@:expose("chr")
	static function fromCharCode(i:Int):String;
	
	static function format(val:Float, total:Int, decimal:Int):String;
}
