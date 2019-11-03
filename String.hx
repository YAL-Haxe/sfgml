package ;
import gml.Lib.raw;
import gml.NativeString;
/**
 * ...
 * @author YellowAfterlife
 */
#if !macro
@:std @:native("string") @:final
class String {
	public var length(get, null):Int;
	private inline function get_length():Int {
		return NativeString.length(this);
	}
	public inline function charAt(i:Int):String {
		return NativeString.charAt(this, i + 1);
	}
	public inline function charCodeAt(i:Int):Int {
		return NativeString.charCodeAt(this, i + 1);
	}
	@:native("pos_ext")
	public function indexOf(sub:String, startPos:Int = 0):Int {
		var hay = startPos > 0 ? NativeString.delete(this, 1, startPos) : this;
		var out = NativeString.pos(sub, hay);
		return out > 0 ? out + startPos - 1 : -1;
	}
	@:native("pos_last")
	public function lastIndexOf(sub:String, ?startPos:Int):Int {
		var i = 0, out = -1;
		if (startPos == null) startPos = length;
		while (true) {
			var p = indexOf(sub, out + 1);
			if (p == -1 || p > startPos) break;
			out = p;
		}
		return out;
	}
	public function split(del:String):Array<String> {
		var str:String = this, num:Int = 0;
		//
		var arr:Array<String> = gml.NativeArray.createEmpty(NativeString.count(del, str) + 1);
		//
		var pos = NativeString.pos(del, str);
		while (pos > 0) {
			arr[num] = NativeString.copy(str, 1, pos - 1);
			num += 1;
			str = NativeString.delete(str, 1, pos);
			pos = NativeString.pos(del, str);
		}
		arr[num] = str;
		//
		return arr;
	}
	public inline function substr(pos:Int, length:Int = 0x7fffffff):String {
		return NativeString.copy(NativeString.delete(this, 1, pos), 1, length);
	}
	public inline function substring(start:Int, end:Int = 0x7fffffff):String {
		return NativeString.delete(NativeString.copy(this, 1, end), 1, start);
	}
	@:extern public inline function toString():String {
		return this;
	}
	@:extern public static inline function fromCharCode(i:Int):String {
		return NativeString.fromCharCode(i);
	}
	public inline function toLowerCase():String {
		return NativeString.lower(this);
	}
	public inline function toUpperCase():String {
		return NativeString.upper(this);
	}
}
#else
extern class String {

	/**
		The number of characters in `this` String.
	**/
	var length(default,null) : Int;

	/**
		Creates a copy from a given String.
	**/
	function new(string:String) : Void;

	/**
		Returns a String where all characters of `this` String are upper case.

		Affects the characters `a-z`. Other characters remain unchanged.
	**/
	function toUpperCase() : String;

	/**
		Returns a String where all characters of `this` String are lower case.

		Affects the characters `A-Z`. Other characters remain unchanged.
	**/
	function toLowerCase() : String;

	/**
		Returns the character at position `index` of `this` String.

		If `index` is negative or exceeds `this.length`, the empty String `""`
		is returned.
	**/
	function charAt(index : Int) : String;

	/**
		Returns the character code at position `index` of `this` String.

		If `index` is negative or exceeds `this.length`, `null` is returned.

		To obtain the character code of a single character, `"x".code` can be
		used instead to inline the character code at compile time. Note that
		this only works on String literals of length 1.
	**/
	function charCodeAt( index : Int) : Null<Int>;

	/**
		Returns the position of the leftmost occurrence of `str` within `this`
		String.

		If `startIndex` is given, the search is performed within the substring
		of `this` String starting from `startIndex`. Otherwise the search is
		performed within `this` String. In either case, the returned position
		is relative to the beginning of `this` String.

		If `str` cannot be found, -1 is returned.
	**/
	function indexOf( str : String, ?startIndex : Int ) : Int;

	/**
		Returns the position of the rightmost occurrence of `str` within `this`
		String.

		If `startIndex` is given, the search is performed within the substring
		of `this` String from 0 to `startIndex`. Otherwise the search is
		performed within `this` String. In either case, the returned position
		is relative to the beginning of `this` String.

		If `str` cannot be found, -1 is returned.
	**/
	function lastIndexOf( str : String, ?startIndex : Int ) : Int;

	/**
		Splits `this` String at each occurrence of `delimiter`.

		If `this` String is the empty String `""`, the result is not consistent
		across targets and may either be `[]` (on Js, Cpp) or `[""]`.

		If `delimiter` is the empty String `""`, `this` String is split into an
		Array of `this.length` elements, where the elements correspond to the
		characters of `this` String.

		If `delimiter` is not found within `this` String, the result is an Array
		with one element, which equals `this` String.

		If `delimiter` is null, the result is unspecified.

		Otherwise, `this` String is split into parts at each occurrence of
		`delimiter`. If `this` String starts (or ends) with `delimiter`, the
		result `Array` contains a leading (or trailing) empty String `""` element.
		Two subsequent delimiters also result in an empty String `""` element.
	**/
	function split( delimiter : String ) : Array<String>;

	/**
		Returns `len` characters of `this` String, starting at position `pos`.

		If `len` is omitted, all characters from position `pos` to the end of
		`this` String are included.

		If `pos` is negative, its value is calculated from the end of `this`
		String by `this.length + pos`. If this yields a negative value, 0 is
		used instead.

		If the calculated position + `len` exceeds `this.length`, the characters
		from that position to the end of `this` String are returned.

		If `len` is negative, the result is unspecified.
	**/
	function substr( pos : Int, ?len : Int ) : String;

	/**
		Returns the part of `this` String from `startIndex` to but not including `endIndex`.

		If `startIndex` or `endIndex` are negative, 0 is used instead.

		If `startIndex` exceeds `endIndex`, they are swapped.

		If the (possibly swapped) `endIndex` is omitted or exceeds
		`this.length`, `this.length` is used instead.

		If the (possibly swapped) `startIndex` exceeds `this.length`, the empty
		String `""` is returned.
	**/
	function substring( startIndex : Int, ?endIndex : Int ) : String;

	/**
		Returns the String itself.
	**/
	function toString() : String;

	/**
		Returns the String corresponding to the character code `code`.

		If `code` is negative or has another invalid value, the result is
		unspecified.
	**/
	@:pure static function fromCharCode( code : Int ) : String;
}

#end
