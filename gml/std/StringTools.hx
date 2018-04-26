package;
import gml.NativeString;
import gml.Lib.raw;
import gml.Lib.div;
/**
 * ...
 * @author YellowAfterlife
 */
@:native("string_hx") @:final @:std
class StringTools {
	public static function urlEncode(s:String):String {
		return null;
	}
	public static function urlDecode(s:String):String {
		return null;
	}
	public static function htmlEscape(s:String, quotes:Bool = false):String {
		s = NativeString.replaceAll(s, "&", "&amp;");
		s = NativeString.replaceAll(s, "<", "&lt;");
		s = NativeString.replaceAll(s, ">", "&gt;");
		if (quotes) {
			s = NativeString.replaceAll(s, '"', "&quot;");
			s = NativeString.replaceAll(s, "'", "&#039;");
		}
		return s;
	}
	public static function htmlUnescape(s:String):String {
		s = NativeString.replaceAll(s, "&gt;" , ">");
		s = NativeString.replaceAll(s, "&lt;" , "<");
		s = NativeString.replaceAll(s, "&quot;", '"');
		s = NativeString.replaceAll(s, "&#039;", "'");
		s = NativeString.replaceAll(s, "&amp;", "&");
		return s;
	}
	public static function startsWith(s:String, z:String):Bool {
		var n:Int = z.length;
		return s.length >= n && NativeString.copy(s, 1, n) == z;
	}
	public static function endsWith(s:String, e:String):Bool {
		var n:Int = s.length;
		var i:Int = e.length;
		return n >= i && NativeString.copy(s, n + 1 - i, i) == e;
	}
	public static function isSpace(s:String, pos:Int):Bool {
		var c = s.charCodeAt(pos);
		return (c > 8 && c < 14) || c == 32;
	}
	public static function ltrim(s:String):String {
		var l:Int = s.length;
		var i:Int = 1;
		while (i <= l) {
			var c:Int = NativeString.charCodeAt(s, i);
			if (c == 32 || (c > 8 && c < 14)) {
				i += 1;
			} else break;
		}
		return i > 1 ? NativeString.delete(s, 1, i - 1) : s;
	}
	public static function rtrim(s:String):String {
		var l:Int = s.length;
		var i:Int = l;
		while (i > 0) {
			var c:Int = NativeString.charCodeAt(s, i);
			if (c == 32 || (c > 8 && c < 14)) {
				i -= 1;
			} else break;
		}
		return i < l ? NativeString.copy(s, 1, i) : s;
	}
	public static function trim(str:String):String {
		var char:Int;
		//
		var len = str.length;
		var till = len;
		while (till > 0) {
			char = NativeString.charCodeAt(str, till);
			if (char == 32 || (char > 8 && char < 14)) {
				till -= 1;
			} else break;
		}
		if (till < len) str = NativeString.copy(str, 1, till);
		//
		var start = 1;
		while (start <= till) {
			char = NativeString.charCodeAt(str, start);
			if (char == 32 || (char > 8 && char < 14)) {
				start += 1;
			} else break;
		}
		if (start > 1) str = NativeString.delete(str, 1, start - 1);
		//
		return str;
	}
	@:extern public static inline function repeat(s:String, n:Int):String {
		return NativeString.repeat(s, n);
	}
	public static function lpad(s:String, c:String, l:Int):String {
		var cl = c.length;
		if (cl <= 0) return s;
		return NativeString.repeat(c, div((l - s.length), cl)) + s;
	}
	public static function rpad(s:String, c:String, l:Int):String {
		var cl = c.length;
		if (cl <= 0) return s;
		return s + NativeString.repeat(c, div((l - s.length), cl));
	}
	@:extern public static inline function replace(s:String, sub:String, by:String):String {
		return NativeString.replaceAll(s, sub, by);
	}
	public static function hex(i:Int, d:Int = 1) {
		var s = "";
		var h = "0123456789ABCDEF";
		if (i < 0) i += cast 4294967295;
		while (i > 0) {
			s = NativeString.charAt(h, 1 + (i & 15)) + s;
			i >>= 4;
		}
		d -= s.length;
		if (d > 0) s = NativeString.repeat("0", d) + s;
		return s;
	}
	public static inline function fastCodeAt(s:String, index:Int):Int {
		return s.charCodeAt(index);
	}
	@:noUsing public static inline function isEof(c:Int):Bool {
		return c < 0;
	}
	//
	public static function quoteWinArg(argument:String, escapeMetaCharacters:Bool):String {
		throw "StringTools.quoteWinArg is not implemented.";
	}
	public static function quoteUnixArg(argument:String):String {
		throw "StringTools.quoteUnixArg is not implemented.";
	}
}
