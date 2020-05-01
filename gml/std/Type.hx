package;
import gml.MetaType;
import gml.NativeArray;
import gml.NativeGlobal;
import gml.NativeString;
import gml.NativeStruct;
import gml.NativeType;
import gml.ds.HashTable;

@:std enum ValueType {
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
@:std @:coreApi class Type {
	private static inline var modernOnly:String = "This method is only available in GMS>=2.3.";
	private static inline var structOnly:String = "This method can only be used with struct values.";
	
	public static inline function getClass<T>(o:T):Class<T> {
		return @:privateAccess js.Boot.getClass(o);
	}
	
	public static function getEnum(o:EnumValue):Enum<Dynamic> {
		#if sfgml.modern
		if (NativeType.isStruct(o)) {
			return NativeStruct.getField(o, "__enum__");
		} else throw structOnly;
		#else
		throw modernOnly;
		#end
	}
	
	public static inline function getSuperClass(c:Class<Dynamic>):Class<Dynamic> {
		#if sfgml.modern
		return (cast c:MetaClass<Dynamic>).superClass;
		#else
		// todo: could store superClass on non-modern
		throw modernOnly;
		#end
	}
	
	public static inline function getClassName(c:Class<Dynamic>):String {
		return (cast c:MetaClass<Dynamic>).name;
	}
	
	public static inline function getEnumName(e:Enum<Dynamic>):String {
		return (cast e:MetaEnum<Dynamic>).name;
	}
	
	public static inline function resolveClass(name:String):Class<Dynamic> {
		return js.Boot.resolveClassMap[name];
	}
	public static inline function resolveEnum(name:String):Enum<Dynamic> {
		return js.Boot.resolveEnumMap[name];
	}
	
	public static function createInstance<T>(cl:Class<T>, args:Array<Dynamic>):T {
		#if sfgml.modern
		if ((cl:MetaClass<T>).index < 0) {
			var ctr = (cl:MetaClass<T>).constructor;
			if (ctr == null) throw "Class does not have a constructor";
			return gml.internal.NativeConstructorInvoke.call(ctr, args);
		}
		throw structOnly;
		#else
		throw modernOnly;
		#end
	}
	
	public static inline function createEmptyInstance<T>(cl:Class<T>):T {
		throw "Type.createEmptyInstance is not supported.";
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
	
	public static function typeof(v:Dynamic):ValueType {
		// many things are indexes so don't get your expectations
		if (v == null) return TNull;
		if (NativeType.isBool(v)) return TBool;
		if (NativeType.isInt32(v) || NativeType.isInt64(v)) return TInt;
		if (NativeType.isReal(v)) return Std.int(v) == v ? TInt : TFloat;
		if (NativeType.isString(v)) return TClass(String);
		#if sfgml.modern
		if (NativeType.isStruct(v)) {
			var q:Dynamic = NativeStruct.getField(v, "__enum__");
			if (q != null) return TEnum(q);
			q = NativeStruct.getField(v, "__class__");
			if (q != null) return TClass(q);
			return TObject;
		}
		if (NativeType.isMethod(v)) return TFunction;
		#end
		return TUnknown;
	}
	
	public static function enumEq<T>(a:T, b:T):Bool {
		if (a == b) return true;
		var i:Int, n:Int;
		#if sfgml.modern
		if (NativeType.isStruct(a)) {
			if (!NativeType.isStruct(b)) return false;
			i = NativeStruct.getField(a, "__enumIndex__");
			if (i == null || i != NativeStruct.getField(b, "__enumIndex__")) return false;
			var params:Array<String> = untyped a.__enumParams__;
			n = params.length;
			i = -1; while (++i < n) {
				var p = params[i];
				if (!enumEq(NativeStruct.getField(a, p), NativeStruct.getField(b, p))) return false;
			}
			return true;
		}
		#end
		if (NativeType.isArray(a) && NativeType.isArray(b)) {
			#if sfgml.modern
			n = (cast a:Array<Dynamic>).length;
			i = -1; while (++i < n) {
				if (!enumEq((cast a:Array<Dynamic>)[i], (cast b:Array<Dynamic>)[i])) return false;
			}
			return true;
			#else
			return NativeArray.equals(cast a, cast b);
			#end
		}
		return false;
	}
	
	public static function createEnum<T>(e:Enum<T>, constr:String, ?params:Array<Dynamic>):T {
		var n = params != null ? params.length : 0;
		var r:Dynamic;
		inline function me():MetaEnum<T> {
			return cast e;
		}
		#if sfgml.modern
		if (me().index < 0) {
			r = NativeGlobal.getField(me().name + "_" + constr);
			if (NativeType.isStruct(r)) return r;
			return gml.internal.NativeFunctionInvoke.call(r, params, n);
		}
		#end
		var ctrs = me().constructors;
		if (ctrs == null) throw 'Enum ${me().name} does not have a constructor array.';
		#if sfgml_legacy_meta
		r = null;
		MetaType.copyset(r, e);
		NativeArray.set2d(r, 0, 0, me().index);
		if (js.Boot.isJS) {
			var i = -1; while (++i < n) {
				NativeArray.set2d(r, 0, i + 1, params[i]);
			}
		} else {
			while (--n >= 0) {
				NativeArray.set2d(r, 0, n + 1, params[n]);
			}
		}
		#else
		r = NativeArray.createEmpty(n + 1);
		r[0] = gml.internal.ArrayImpl.indexOf(ctrs, constr, 0);
		if (n > 0) NativeArray.copyPart(r, 1, params, 0, n);
		#end
		return r;
	}
	
	public static function createEnumIndex<T>(e:Enum<T>, index:Int, ?params:Array<Dynamic>):T {
		var n = params != null ? params.length : 0;
		var r:Dynamic;
		#if sfgml.modern
		inline function me():MetaEnum<T> {
			return cast e;
		}
		if (me().index < 0) {
			var ctrs = me().constructors;
			if (ctrs == null) throw 'Enum ${me().name} does not have a constructor array.';
			r = NativeGlobal.getField(me().name + "_" + ctrs[index]);
			if (NativeType.isStruct(r)) return r;
			return gml.internal.NativeFunctionInvoke.call(r, params, n);
		}
		#end
		#if sfgml_legacy_meta
		r = null;
		MetaType.copyset(r, e);
		NativeArray.set2d(r, 0, 0, index);
		if (js.Boot.isJS) {
			var i = -1; while (++i < n) {
				NativeArray.set2d(r, 0, i + 1, params[i]);
			}
		} else {
			while (--n >= 0) {
				NativeArray.set2d(r, 0, n + 1, params[n]);
			}
		}
		#else
		r = NativeArray.createEmpty(n + 1);
		r[0] = index;
		if (n > 0) NativeArray.copyPart(r, 1, params, 0, n);
		#end
		return r;
	}
	
	public static function getEnumConstructs(e:Enum<Dynamic>):Array<String> {
		// also see SfGmlEnumCtr and SfGml_ArrayImpl;
		// we reserve copy() for fake enums
		return (cast e:MetaEnum<Dynamic>).constructors.copy();
	}
	
	public static function enumConstructor(e:EnumValue):String {
		// also see SfGmlEnumCtr
		var et:MetaEnum<EnumValue>, i:Int;
		#if sfgml.modern
		var isStruct = NativeType.isStruct(e);
		if (isStruct) {
			et = untyped e.__enum__;
			i = untyped e.__enumIndex__;
		} else
		#end
		#if sfgml_legacy_meta
		if (MetaType.has(e)) {
			et = cast MetaType.get(e);
			i = untyped e[0];
		} else
		#end
		return NativeType.toString(e);
		//
		var cs = et.constructors;
		if (cs != null && i >= 0 && i < cs.length) {
			return cs[i];
		} else {
			#if sfgml.modern
			if (isStruct) {
				var s = NativeStruct.instanceOf(e);
				if (NativeString.copy(s, 1, 3) == "mc_") {
					s = NativeString.delete(s, 1, 3);
				}
				i = et.name.length;
				if (NativeString.copy(s, 1, i) == et.name
					&& NativeString.charCodeAt(s, i + 1) == "_".code
				) s = NativeString.delete(s, 1, i + 1);
				return s;
			}
			#end
			return NativeType.toString(e);
		}
	}
	
	public static function enumParameters(e:EnumValue):Array<Dynamic> {
		var n:Int, r:Array<Dynamic>;
		#if sfgml.modern
		if (NativeType.isStruct(e)) {
			// { a: 1, b: 2, c: 3, __enumParams__: ["a", "b", "c"] } -> [1, 2, 3]
			var fields:Array<String> = untyped e.__enumParams__;
			n = fields.length;
			r = NativeArray.createEmpty(n);
			var i = -1; while (++i < n) {
				r[i] = NativeStruct.getField(e, fields[i]);
			}
			return r;
		}
		#end
		if (NativeType.isArray(e)) { // [index, 1, 2, 3] -> [1, 2, 3]
			var m:Array<Dynamic> = cast e;
			#if !sfgml_legacy_meta
				n = m.length - 1;
				r = NativeArray.createEmpty(n);
				NativeArray.copyPart(r, 0, m, 1, n);
				return r;
			#else
				n = NativeArray.cols2d(m, 0);
				r = NativeArray.createEmpty(n - 1);
				while (--n >= 0) r[n - 1] = m[n];
				return r;
			#end
		} else return []; // perhaps a fake enum
	}
	
	#if sfgml.modern
	public static function enumIndex(e:EnumValue):Int {
		// also see SfGmlEnumCtr
		if (NativeType.isStruct(e)) {
			return untyped e.__enumIndex__;
		} else if (NativeType.isArray(e)) {
			return untyped e[0];
		} else return cast e;
	}
	#else
	public static inline function enumIndex(e:EnumValue):Int {
		return untyped e[0];
	}
	#end
	
	public static inline function allEnums<T>(e:Enum<T>):Array<T> {
		throw "Type.allEnums is not supported.";
		return null;
	}
}

