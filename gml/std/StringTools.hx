package;
import gml.NativeArray;
import gml.NativeString;
import gml.Lib.raw;
import gml.Syntax.div;
import gml.io.Buffer;
import haxe.ds.Vector;
/**
 * ...
 * @author YellowAfterlife
 */
@:std @:coreApi
class StringTools {
	private static var urlEncode_in:Buffer = Buffer.defValue;
	private static var urlEncode_out:Buffer = Buffer.defValue;
	private static var urlEncode_esc:Array<Bool> = null;
	private static var urlEncode_hex:Array<Int> = null;
	private static function urlEncode_init():Buffer {
		//
		var arr = NativeArray.create(256, true), i:Int;
		i = "A".code; while (i <= "Z".code) arr[i++] = false;
		i = "a".code; while (i <= "z".code) arr[i++] = false;
		i = "0".code; while (i <= "9".code) arr[i++] = false;
		arr["-".code] = false;
		arr["_".code] = false;
		arr[".".code] = false;
		arr["!".code] = false;
		arr["~".code] = false;
		arr["*".code] = false;
		arr["'".code] = false;
		arr["(".code] = false;
		arr[")".code] = false;
		urlEncode_esc = arr;
		//
		var hex = NativeArray.create(256, 0);
		for (i in 0 ... 256) {
			var h = i >> 4, v = 0;
			if (h < 10) v += "0".code + h; else v += "A".code - 10 + h;
			h = i & 15;
			if (h < 10) v += ("0".code + h) * 256; else v += ("A".code - 10 + h) * 256;
			hex[i] = v;
		}
		urlEncode_hex = hex;
		//
		urlEncode_out = new Buffer(1024, Grow, 1);
		return new Buffer(1024, Grow, 1);
	}
	public static function urlEncode(s:String):String {
		var inb = urlEncode_in;
		if (inb == Buffer.defValue) inb = urlEncode_init();
		var outb = urlEncode_out;
		var esc = urlEncode_esc;
		var hex = urlEncode_hex;
		inb.rewind();
		inb.writeChars(s);
		var n = inb.position;
		inb.rewind();
		outb.rewind();
		for (_ in 0 ... n) {
			var b = inb.readByte();
			if (esc[b]) {
				outb.writeByte("%".code);
				outb.writeShort(hex[b]);
			} else outb.writeByte(b);
		}
		outb.writeByte(0);
		outb.rewind();
		return outb.readString();
	}
	public static function urlDecode(s:String):String {
		throw "Not implemented";
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
	
	public inline static function contains(s:String, value:String):Bool {
		return s.indexOf(value) != -1;
	}
	
	public static function startsWith(s:String, start:String):Bool {
		var n:Int = start.length;
		return s.length >= n && NativeString.copy(s, 1, n) == start;
	}
	public static function endsWith(s:String, end:String):Bool {
		var n:Int = s.length;
		var i:Int = end.length;
		return n >= i && NativeString.copy(s, n + 1 - i, i) == end;
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
	public static function trim(s:String):String {
		var char:Int;
		//
		var len = s.length;
		var till = len;
		while (till > 0) {
			char = NativeString.charCodeAt(s, till);
			if (char == 32 || (char > 8 && char < 14)) {
				till -= 1;
			} else break;
		}
		if (till < len) s = NativeString.copy(s, 1, till);
		//
		var start = 1;
		while (start <= till) {
			char = NativeString.charCodeAt(s, start);
			if (char == 32 || (char > 8 && char < 14)) {
				start += 1;
			} else break;
		}
		if (start > 1) s = NativeString.delete(s, 1, start - 1);
		//
		return s;
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
	public static function hex(n:Int, ?digits:Int):String {
		var s = "";
		var h = "0123456789ABCDEF";
		if (n < 0) n += cast 4294967295;
		while (n > 0) {
			s = NativeString.charAt(h, 1 + (n & 15)) + s;
			n >>= 4;
		}
		if (digits != null) {
			digits -= s.length;
			if (digits > 0) s = NativeString.repeat("0", digits) + s;
		}
		return s;
	}
	public static inline function fastCodeAt(s:String, index:Int):Int {
		return s.charCodeAt(index);
	}
	
	#if (haxe >= "4.0.0")
	public static inline function iterator(s:String):haxe.iterators.StringIterator {
		return new haxe.iterators.StringIterator(s);
	}

	public static inline function keyValueIterator(s:String):haxe.iterators.StringKeyValueIterator {
		return new haxe.iterators.StringKeyValueIterator(s);
	}
	#end
	
	@:noUsing public static inline function isEof(c:Int):Bool {
		return c < 0;
	}
	
	
	@:noCompletion
	@:deprecated('StringTools.quoteUnixArg() is deprecated. Use haxe.SysTools.quoteUnixArg() instead.')
	public static function quoteUnixArg(argument:String):String {
		return inline haxe.SysTools.quoteUnixArg(argument);
	}
	
	@:noCompletion
	@:deprecated('StringTools.winMetaCharacters is deprecated. Use haxe.SysTools.winMetaCharacters instead.')
	public static var winMetaCharacters:Array<Int> = cast haxe.SysTools.winMetaCharacters;
	
	@:noCompletion
	@:deprecated('StringTools.quoteWinArg() is deprecated. Use haxe.SysTools.quoteWinArg() instead.')
	public static function quoteWinArg(argument:String, escapeMetaCharacters:Bool):String {
		return inline haxe.SysTools.quoteWinArg(argument, escapeMetaCharacters);
	}
	
	#if utf16
	static inline var MIN_SURROGATE_CODE_POINT = 65536;

	static inline function utf16CodePointAt(s:String, index:Int):Int {
		var c = StringTools.fastCodeAt(s, index);
		if (c >= 0xD800 && c <= 0xDBFF) {
			c = ((c - 0xD7C0) << 10) | (StringTools.fastCodeAt(s, index + 1) & 0x3FF);
		}
		return c;
	}
	#end
}
