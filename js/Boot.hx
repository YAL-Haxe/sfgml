package js;
import gml.MetaType;
import gml.NativeArray;
import gml.NativeString;
import gml.NativeStruct;
import gml.NativeType;
import gml.io.Buffer;
import gml.sys.System;
import gml.ds.HashTable;
import gml.internal.ArrayImpl;

/**
 * Just like the JS version, this class is a bit of a dump for various helper functions.
 * @author YellowAfterlife
 */
@:native("haxe.boot") @:std
class Boot {
	
	/** Whether currently exported to JavaScript */
	public static var isJS:Bool = untyped os_browser != browser_not_a_browser;
	
	private static function __trace(v, i:haxe.PosInfos) {
		trace(v);
	}
	@:native("get_class")
	private static function getClass<T>(o:T):Class<T> {
		if (MetaType.has(o)) {
			var r = MetaType.get(o);
			#if !sfgml_legacy_meta
			return cast r;
			#else
			if (MetaType.has(r)) {
				return cast r;
			}
			#end
		}
		return null;
	}
	
	private static function __string_rec(o:Dynamic, s:String):String {
		return Std.string(o);
	}
	private static function __interfLoop(cc:Dynamic, cl:Dynamic):Bool {
		throw "Can't do";
	}
	static function __implements(o:Dynamic, iface:Class<Dynamic>):Bool {
		throw "Can't do";
	}
	@:ifFeature("typed_catch")
	private static function __instanceof(o:Dynamic, c:Dynamic):Bool {
		return false;
	}
	@:ifFeature("typed_cast")
	private static function __cast(o:Dynamic, t:Dynamic):Dynamic {
		return o;
	}
	static function __nativeClassName(o:Dynamic):String {
		return null;
	}
	static function __isNativeObj(o:Dynamic):Bool {
		return false;
	}
	static function __resolveNativeClass(name:String):Dynamic {
		return null;
	}
	static function isClass(q:Dynamic):Bool {
		return false;
	}
	static function isEnum(q:Dynamic):Bool {
		return false;
	}
	
	/** Is used in array declaration `[e1, e2, ..., eN]` for GMS1. */
	@:keep private static function decl<T>(values:SfRest<T>):Array<T> {
		var n:Int = values.length, i:Int, r:Array<T>;
		if (n == 0) {
			#if (sfgml_array_create)
			return NativeArray.createEmpty(0);
			#else
			r = null;
			NativeArray.copyset2d(r, 1, 0, null);
			return r;
			#end
		}
		//
		if (System.isBrowser) {
			r = null;
			r[0] = values[0];
			i = 0; while (++i < n) NativeArray.copyset(r, i, values[i]);
		} else {
			r = null;
			while (--n >= 0) NativeArray.copyset(r, n, values[n]);
		}
		return r;
	}
	
	/**
	 * Appends up to 15 elements to the end of given array (legacy GMS1 only).
	 * Is used in inline array declaration for trailing groups of elements.
	 */
	@:keep private static function trail<T>(array:Array<T>, values:T) {
		var o:Int = array.length - 1;
		var i:Int = gml.Lib.argc;
		while (--i > 0) array[o + i] = gml.Lib.args[i];
		return array;
	}
	
	/** { a: 1, b: 2 } -> odecl("a", 1, "b", 2) */
	@:keep private static function odecl<T:Dynamic>(meta:String, size:Int, pairs:Dynamic):T {
		var r:Array<Dynamic>;
		var i:Int;
		#if (sfgml_array_create)
		r = NativeArray.create(size, null);
		#else
		r = null;
		if (System.isBrowser) {
			i = 0; while (i < size) NativeArray.copyset(r, i, null);
		} else {
			i = size; while (--i >= 0) NativeArray.copyset(r, i, null);
		}
		#end
		#if sfgml_legacy_meta
		MetaType.set(r, meta);
		#end
		var n:Int = gml.Lib.argc;
		i = 2;
		while (i < n) {
			r[gml.Lib.args[i]] = gml.Lib.args[i + 1];
			i += 2;
		}
		return cast r;
	}
	
	/** ds_map literal function */
	@:keep private static function mdecl<T:Dynamic>(pairs:SfRestMixed):T {
		var r = new gml.ds.HashTable();
		var i = 0;
		var n = pairs.length;
		while (i < n) {
			r.set(pairs[i], pairs[i + 1]);
			i += 2;
		}
		return cast r;
	}
	
	/** Ternary function for GMS1. Better than a compile error, you know */
	@:pure @:keep private static function tern<T>(c:Bool, a:T, b:T):T {
		return c ? a : b;
	}
	
	//{ pre-2.3 functions to replace chained accessors
	@:pure @:keep public static function wget<T>(arr:Array<T>, index:Int):T {
		return arr[index];
	}
	@:keep public static function wset<T>(arr:Array<T>, index:Int, value:T):Void {
		arr[index] = value;
	}
	//}
	
	#if (sfgml_catch_error)
	@:keep private static function catch_error():js.lib.Error {
		var s:String = SfTools.raw("catch_error_dequeue")();
		SfTools.raw("catch_error_clear")();
		var e = new js.lib.Error();
		e.parseGMError(s);
		return e;
	}
	#end
	
	//{ closure tricks: some.method -> closure_post(closure_pre(self).method)
	@:keep public static var closureSelf:Dynamic;
	@:keep public static function closurePre(self:Dynamic):Dynamic {
		closureSelf = self;
		return self;
	}
	@:keep public static function closurePost(func:Dynamic):Dynamic {
		var result = gml.NativeFunction.bind(closureSelf, func);
		closureSelf = null;
		return result;
	}
	//}
	
	//{
	public static var resolveClassMap:HashTable<String, Class<Dynamic>> = HashTable.defValue;
	public static var resolveEnumMap:HashTable<String, Enum<Dynamic>> = HashTable.defValue;
	//}
}

#if !sfgml_catch_error @:remove #end
private class HaxeError extends js.lib.Error {
	var val:Dynamic;
	//
	private static var concatBuf:Buffer = Buffer.defValue;
	@:pure public function new(val:Dynamic) {
		super();
		this.val = val;
		//
		var b = concatBuf;
		if (b == Buffer.defValue) {
			b = new Buffer(1024, Grow, 1);
			concatBuf = b;
		}
		b.rewind();
		var stack:Array<String> = SfTools.raw("debug_get_callstack")();
		for (i in 1 ... stack.length) { // (excluding this item)
			if (i > 1) b.writeChars("\r\n");
			b.writeChars(stack[i]);
		}
		b.writeByte(0);
		b.rewind();
		//
		this.name = "HaxeError";
		this.message = Std.string(val);
		this.stack = b.readString();
	}
	//
	public static function wrap(val:Dynamic):js.lib.Error {
		return if (js.Syntax.instanceof(val, js.lib.Error)) val else new HaxeError(val);
	}
}
