package js;
import gml.MetaType;
import gml.NativeArray;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("haxe.boot")
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
			if (MetaType.has(r)) {
				return cast r;
			}
		}
		return null;
	}
	private static function __string_rec(o:Dynamic, s:String):String {
		return Std.string(o);
	}
	private static function __interfLoop(cc:Dynamic, cl:Dynamic):Void {
		
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
		var i:Int = values.length;
		var r:Array<T>;
		#if (sfgml_version && sfgml_version <= 1763)
		r = null; MetaType.copyset(r, null);
		#else
		r = NativeArray.create(i);
		#end
		while (--i >= 0) NativeArray.copyset(r, i, values[i]);
		return r;
	}
	
	/**
	 * Appends up to 15 elements to the end of given array (GMS1 only).
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
		var i:Int = size;
		#if (sfgml_version && sfgml_version <= 1763)
		r = null;
		#else
		r = NativeArray.create(i);
		#end
		MetaType.copyset(r, meta);
		while (--i >= 0) r[i] = null;
		var n:Int = gml.Lib.argc;
		i = 2;
		while (i < n) {
			r[gml.Lib.args[i]] = gml.Lib.args[i + 1];
			i += 2;
		}
		return cast r;
	}
	
	/** Ternary function for GMS1. Better than a compile error, you know */
	@:pure @:keep private static function tern<T>(c:Bool, a:T, b:T):T {
		return c ? a : b;
	}
	
	@:pure @:keep public static function wget<T>(arr:Array<T>, index:Int):T {
		return arr[index];
	}
	@:keep public static function wset<T>(arr:Array<T>, index:Int, value:T):Void {
		arr[index] = value;
	}
}

@:remove private class HaxeError extends js.Error {
	var val:Dynamic;
	@:pure public function new(val:Dynamic) {
		super();
	}
	public static function wrap(val:Dynamic):js.Error {
		return if (js.Syntax.instanceof(val, js.Error)) val else new HaxeError(val);
	}
	public static function create(v:Dynamic) {
		return v;
	}
}
