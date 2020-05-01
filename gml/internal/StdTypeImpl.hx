package gml.internal;
import gml.MetaType;

/**
 * Houses various helpers for Std.is
 * Is processed/culled by SfGml_StdTypeImpl
 * @author YellowAfterlife
 */
@:std class StdTypeImpl {
	
	#if !sfgml.modern
	/** Used for Std.is(v, Float) in pre-2.3 */
	@:keep static function isNumber(v:Dynamic):Bool {
		return NativeType.isReal(v)
			|| NativeType.isBool(v)
			|| NativeType.isInt32(v)
			|| NativeType.isInt64(v);
	}
	#end
	
	/** Used for Std.is(v, Int) */
	@:keep static function isIntNumber(value:Dynamic):Bool {
		if (NativeType.isReal(value)) {
			return (value | 0) == value;
		}
		#if sfgml.modern
		return NativeType.isNumber(value);
		#else
		return NativeType.isInt64(value)
			|| NativeType.isInt32(value)
			|| NativeType.isBool(value);
		#end
	}
	
	public static function is(value:Dynamic, type:Dynamic) {
		inline function isNumber(v:Dynamic) {
			#if sfgml.modern
			return NativeType.isNumber(value);
			#else
			return NativeType.isReal(value)
				|| NativeType.isInt64(value)
				|| NativeType.isInt32(value)
				|| NativeType.isBool(value);
			#end
		}
		if (type == null) return false;
		switch (type) {
			// we'll auto-insert some cases here depending on generated types
			case Array: return NativeType.isArray(value);
			case Bool: return NativeType.isBool(value);
			case Float: return isNumber(value);
			case Int: return inline isIntNumber(value);
			case Class: return NativeStruct.getField(value, "__class__") == "class";
			case Enum: return NativeStruct.getField(value, "__class__") == "enum";
			case String: return NativeType.isString(value);
			case Dynamic: return value != null;
			default: {
				if (value == null) return false;
				#if sfgml.modern
				if (!NativeType.isStruct(type)) return false;
				#else
				if (!NativeType.isArray(type)) return false;
				#end
				
				//
				var mt:MetaType<Dynamic>;
				#if sfgml.modern
				if (NativeType.isStruct(value)) {
					mt = NativeStruct.getField(value, "__class__");
					if (mt == null) {
						mt = NativeStruct.getField(value, "__enum__");
						if (mt == null) return false;
					}
				} else // ->
				#end
				if (MetaType.has(value)) {
					mt = MetaType.get(value);
				} else if (isNumber(value)) {
					mt = null;
					for (q in NativeScope.with(value, Instance)) {
						mt = q.getField("__class__");
					}
					if (mt == null) return false;
				} else return false;
				
				//
				#if sfgml.modern
				if (mt == type) return true;
				if (NativeType.isStruct(mt) && NativeStruct.hasField(mt, "superClass")) {
					var mc:MetaClass<Dynamic> = untyped mt.superClass;
					while (NativeType.isStruct(mc)) {
						if (mc == type) return true;
						mc = mc.superClass;
					}
				}
				return false;
				#else
				var vti:Int = isNumber(mt) ? cast mt : mt.index;
				var tt:MetaType<Any> = cast type;
				return MetaType.is.get(vti, tt.index);
				#end
			};
		}
	}
}