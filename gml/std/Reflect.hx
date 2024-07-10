package;
import gml.MetaType;
import gml.NativeArray;
import gml.NativeFunction;
import gml.NativeStruct;
import gml.NativeType;
import gml.internal.NativeFunctionInvoke;

/**
 * ...
 * @author YellowAfterlife
 */
@:coreApi @:std class Reflect {
	
	private static inline var modernOnly:String = "This method is only available in GMS>=2.3.";
	private static inline var structOnly:String = "This method can only be used with struct values.";

	@:pure
	public static function hasField(o:Dynamic, field:String):Bool {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			return NativeStruct.hasField(o, field);
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}

	@:pure
	public static function field(o:Dynamic, field:String):Dynamic {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			return NativeStruct.getField(o, field);
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}

	public inline static function setField(o:Dynamic, field:String, value:Dynamic):Void {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			return NativeStruct.setField(o, field, value);
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}

	public static function getProperty(o:Dynamic, field:String):Dynamic {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			var getter:Void->Dynamic = NativeStruct.getField(o, "get_" + field);
			if (NativeType.isMethod(getter)) {
				return NativeFunction.bind(o, getter)();
			}
			return NativeStruct.getField(o, field);
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}

	public static function setProperty(o:Dynamic, field:String, value:Dynamic):Void {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			var setter:Dynamic->Void = NativeStruct.getField(o, "set_" + field);
			if (NativeType.isMethod(setter)) {
				NativeFunction.bind(o, setter)(value);
			} else {
				NativeStruct.setField(o, field, value);
			}
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}

	public static function callMethod(o:Dynamic, func:haxe.Constraints.Function, args:Array<Dynamic>):Dynamic {
		#if sfgml.modern
		var mt:Dynamic = NativeFunction.bind(o, func);
		return inline NativeFunctionInvoke.call(mt, args, args.length);
		#else
		throw modernOnly;
		#end
	}

	public static function fields(o:Dynamic):Array<String> {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			return NativeStruct.getFieldNames(o);
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}

	public static function isFunction(f:Dynamic):Bool {
		return (
			#if sfgml.modern
			NativeType.isMethod(f) ||
			#end
			NativeType.isNumber(f) && gml.assets.Script.isValid(f)
		);
	}
	
	private static var compare_1 = new gml.ds.Grid<Dynamic>(1, 2);
	public static function compare<T>(a:T, b:T):Int {
		if (a != b) {
			var g = compare_1;
			g.set(0, 0, a);
			g.set(0, 1, b);
			g.sort(0, false);
			var z = g.get(0, 0) == a;
			g.clear(null);
			return z ? 1:-1;
		} else return 0;
	}

	public static function compareMethods(f1:Dynamic, f2:Dynamic):Bool {
		#if sfgml.modern
		if (NativeType.isMethod(f1)) {
			return(NativeType.isMethod(f2)
				&& NativeFunction.getSelf(f1) == NativeFunction.getSelf(f2)
				&& NativeFunction.getScript(f1) == NativeFunction.getScript(f2)
			);
		}
		#end
		return f1 == f2;
	}
	
	public static inline function isObject(v:Dynamic):Bool {
		return (
			#if sfgml.modern
			NativeType.isStruct(v) ||
			#end
			NativeType.isArray(v)
		);
	}
	
	public static inline function isEnumValue(v:Dynamic):Bool {
		return (
			#if sfgml.modern
			NativeType.isStruct(v) ||
			#end
			NativeType.isArray(v)
		);
	}

	public static function deleteField(o:Dynamic, field:String):Bool {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			#if (sfgml_version >= "2.3.1")
			gml.NativeStruct.deleteField(o, field);
			#else
			// new enough for structs, not new enough for field deletion
			setField(o, field, null);
			#end
			return true;
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}

	public static function copy<T>(o:T):T {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			// this will fail for objects with prototypes
			var fields = NativeStruct.getFieldNames(cast o);
			var r:T = cast {};
			for (i in 0 ... fields.length) {
				var fd:String = fields[i];
				NativeStruct.setField(cast r, fd, NativeStruct.getField(cast o, fd));
			}
			return r;
		} else
		#end
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

	@:overload(function(f:Array<Dynamic>->Void):Dynamic {})
	public static function makeVarArgs(f:Array<Dynamic>->Dynamic):Dynamic {
		#if sfgml.modern
		return NativeFunction.bind(f, function(rest:SfRest<Dynamic>):Dynamic {
			var argc = rest.length;
			var args = NativeArray.createEmpty(argc);
			var i = -1; while (++i < argc) args[i] = rest[i];
			var fn = gml.NativeScope.self;
			// https://bugs.yoyogames.com/view.php?id=31707 - can't just self()
			return untyped __raw__("{0}", fn(), fn);
		});
		#else
		throw modernOnly + " Consider using SfRest?";
		#end
	}

}
