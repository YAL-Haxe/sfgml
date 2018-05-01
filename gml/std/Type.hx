package;
import gml.MetaType;
import gml.NativeArray;

enum ValueType {
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass(c:Class<Dynamic>);
	TEnum(e:Enum<Dynamic>);
	TUnknown;
}

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("haxe_type_tools") @:snakeCase
@:coreApi class Type {
	public static inline function getClass<T>(o:T):Class<T> {
		return @:privateAccess js.Boot.getClass(o);
	}
	
	public static inline function getEnum(o:EnumValue):Enum<Dynamic> {
		throw "Type.getEnum is not supported.";
		return null;
	}
	
	public static inline function getSuperClass(c:Class<Dynamic>):Class<Dynamic> {
		throw "Type.getSuperClass is not supported.";
		return null;
	}
	
	public static inline function getClassName(c:Class<Dynamic>):String {
		throw "Type.getClassName is not supported.";
		return null;
	}
	
	public static inline function getEnumName(e:Enum<Dynamic>):String {
		throw "Type.getEnumName is not supported.";
		return null;
	}
	
	public static inline function resolveClass(name:String):Class<Dynamic> {
		throw "Type.resolveClass is not supported.";
		return null;
	}
	
	public static inline function resolveEnum(name:String):Enum<Dynamic> {
		throw "Type.resolveEnum is not supported.";
		return null;
	}
	
	public static inline function createInstance<T>(cl:Class<T>, args:Array<Dynamic>):T {
		throw "Type.createInstance is not supported.";
		return null;
	}
	
	public static inline function createEmptyInstance<T>(cl:Class<T>):T {
		throw "Type.createEmptyInstance is not supported.";
		return null;
	}
	
	public static inline function createEnum<T>(e:Enum<T>, constr:String, ?params:Array<Dynamic>):T {
		throw "Type.createEnum is not supported.";
		return null;
	}
	
	public static inline function createEnumIndex<T>(e:Enum<T>, index:Int, ?params:Array<Dynamic>):T {
		throw "Type.createEnumIndex is not supported.";
		return null;
	}
	
	public static inline function getInstanceFields(c:Class<Dynamic>):Array<String> {
		throw "Type.getInstanceFields is not supported.";
		return null;
	}
	
	public static inline function getClassFields(c:Class<Dynamic>):Array<String> {
		throw "Type.getClassFields is not supported.";
		return null;
	}
	
	public static inline function getEnumConstructs(e:Enum<Dynamic>):Array<String> {
		throw "Type.getEnumConstructs is not supported.";
		return null;
	}
	
	public static inline function typeof(v:Dynamic):ValueType {
		throw "Type.typeof is not supported.";
		return null;
	}
	
	public static inline function enumEq<T>(a:T, b:T):Bool {
		throw "Type.enumEq is not supported.";
		return false;
	}
	
	public static function enumConstructor(e:EnumValue):String {
		if (gml.MetaType.has(e)) {
			var et:gml.MetaType.MetaEnum<EnumValue> = cast gml.MetaType.get(e);
			var cs = et.constructors;
			var i = enumIndex(e);
			if (cs != null && i >= 0 && i < cs.length) {
				return cs[i];
			} else return Std.string(e);
		} else return Std.string(e);
	}
	
	public static function enumParameters(e:EnumValue):Array<Dynamic> {
		var m:Array<Dynamic> = cast e;
		var n = NativeArray.cols2d(m, 0);
		var r = NativeArray.create(n - 1);
		while (--n >= 0) r[n - 1] = m[n];
		return r;
	}
	
	public static inline function enumIndex(e:EnumValue):Int {
		return untyped e[0];
	}
	
	public static inline function allEnums<T>(e:Enum<T>):Array<T> {
		throw "Type.allEnums is not supported.";
		return null;
	}
}

