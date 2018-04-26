package;
import gml.MetaType;
import gml.NativeArray;

/**
 * ...
 * @author YellowAfterlife
 */
@:coreApi class Reflect {

	@:pure
	public inline static function hasField( o : Dynamic, field : String ) : Bool {
		throw "Not implemented at this time";
	}

	@:pure
	public static function field( o : Dynamic, field : String ) : Dynamic {
		throw "Not implemented at this time";
	}

	public inline static function setField( o : Dynamic, field : String, value : Dynamic ) : Void {
		throw "Not implemented at this time";
	}

	public static function getProperty( o : Dynamic, field : String ) : Dynamic untyped {
		throw "Not implemented at this time";
	}

	public static function setProperty( o : Dynamic, field : String, value : Dynamic ) : Void untyped {
		throw "Not implemented at this time";
	}

	public inline static function callMethod( o : Dynamic, func : haxe.Constraints.Function, args : Array<Dynamic> ) : Dynamic {
		throw "Not implemented at this time";
	}

	public static function fields( o : Dynamic ) : Array<String> {
		throw "Not implemented at this time";
	}

	public static function isFunction(f:Dynamic):Bool {
		return Std.is(f, Float) && gml.assets.Script.isValid(f);
	}
	
	private static var compare_1 = new gml.ds.Grid<Dynamic>(1, 2);
	public static function compare<T>( a : T, b : T ) : Int {
		if (a != b) {
			var g = compare_1;
			g.set(0, 0, a);
			g.set(0, 1, b);
			g.sort(0, false);
			var z = g.get(0, 0) == a;
			g.clear(null);
			return z ? 1 : -1;
		} else return 0;
	}

	public static inline function compareMethods( f1 : Dynamic, f2 : Dynamic ) : Bool {
		return f1 == f2;
	}

	public static inline function isObject( v : Dynamic ) : Bool {
		return Std.is(v, Array);
	}
	public static inline function isEnumValue( v : Dynamic ) : Bool {
		return Std.is(v, Array);
	}

	public static function deleteField( o : Dynamic, field : String ) : Bool {
		throw "Cannot be implemented - there's no dynamic access";
	}

	public static function copy<T>(o:T):T {
		if (Std.is(o, Array)) {
			var a:Array<Dynamic> = cast o;
			if (a.length > 0) {
				NativeArray.copyset(a, 0, a[0]);
			} else {
				var k = NativeArray.rows2d(a) - 1;
				if (k >= 0) {
					NativeArray.copyset2d(a, k, 0, NativeArray.get2d(a, k, 0));
				} else return cast [];
			}
			return cast a;
		} else return o;
	}

	@:overload(function( f : Array<Dynamic> -> Void ) : Dynamic {})
	public static function makeVarArgs( f : Array<Dynamic> -> Dynamic ) : Dynamic {
		throw "Cannot be implemented for now - please use SfRest instead";
	}

}
