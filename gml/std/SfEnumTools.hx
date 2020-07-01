package;
import gml.NativeArray;
import gml.NativeStruct;
import gml.NativeType;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("haxe_enum_tools")
class SfEnumTools {
	#if sfgml.modern
	public static function getParameter(q:EnumValue, i:Int):Dynamic {
		if (NativeType.isStruct(q)) {
			var params = (cast q).__enumParams__;
			return NativeStruct.getField(q, params[i]);
		} else if (NativeType.isArray(q)) {
			return SfGmlEnumValue.fromEnumValue(q).get(i + 1);
		} else throw "Not an EnumValue";
	}
	
	public static function getParameterCount(q:EnumValue):Int {
		if (NativeType.isStruct(q)) {
			var params = (cast q).__enumParams__;
			return params.length;
		} else if (NativeType.isArray(q)) {
			return SfGmlEnumValue.fromEnumValue(q).length - 1;
		} else throw "Not an EnumValue";
	}
	
	public static function setParameter(q:EnumValue, i:Int, value:Dynamic):Void {
		if (NativeType.isStruct(q)) {
			var params = (cast q).__enumParams__;
			NativeStruct.setField(q, params[i], value);
		} else if (NativeType.isArray(q)) {
			SfGmlEnumValue.fromEnumValue(q).set(i + 1, value);
		} else throw "Not an EnumValue";
	}
	
	public static function setTo<T:EnumValue>(q:T, v:T):Void {
		if (NativeType.isStruct(q)) {
			var qp:Array<String> = (cast q).__enumParams__;
			var vp:Array<String> = (cast v).__enumParams__;
			// clear the existing params:
			var n = qp.length, i = -1;
			while (++i < n) NativeStruct.setField(q, qp[i], null);
			// copy params:
			i = -1; n = vp.length;
			while (++i < n) NativeStruct.setField(q, vp[i], NativeStruct.getField(v, vp[i]));
			//
			(cast q).__enumParams__ = vp;
			(cast q).__enumIndex__ = (cast v).__enumIndex__;
		} else if (NativeType.isArray(q)) {
			var qx = SfGmlEnumValue.fromEnumValue(q);
			var vx = SfGmlEnumValue.fromEnumValue(v);
			var n = vx.length;
			if (qx.length != n) qx.resize(n);
			NativeArray.copyPart(qx, 0, vx, 0, n);
		} else throw "Not an EnumValue";
	}
	
	#else
	
	public static inline function getParameter(q:EnumValue, i:Int):Dynamic {
		return SfGmlEnumValue.fromEnumValue(q).get(i + 1);
	}
	
	public static inline function getParameterCount(q:EnumValue):Int {
		return SfGmlEnumValue.fromEnumValue(q).length - 1;
	}
	
	public static inline function setParameter(q:EnumValue, i:Int, v:Dynamic):Void {
		return SfGmlEnumValue.fromEnumValue(q).set(i + 1, v);
	}
	
	@:native("set")
	public static function setTo<T:EnumValue>(q:T, v:T):Void {
		var qx = SfGmlEnumValue.fromEnumValue(q);
		var vx = SfGmlEnumValue.fromEnumValue(v);
		#if (debug)
		if (gml.NativeArray.cols2d(qx, 1) > 1) {
			gml.NativeArray.set2d(qx, 1, 1, gml.NativeArray.get2d(vx, 1, 1));
		}
		#end
		for (i in 0 ... vx.length) {
			qx.set(i, vx.get(i));
		}
	}
	#end
}
#if sfgml.modern
@:forward("resize")
#end
@:std private abstract SfGmlEnumValue(Array<Dynamic>) to Array<Dynamic> from Array<Dynamic> {
	@:from public static inline function fromEnumValue(v:EnumValue):SfGmlEnumValue return cast v;
	//
	public var length(get, never):Int;
	private inline function get_length():Int return this.length;
	//
	public inline function get(i:Int):Dynamic return this[i];
	public inline function set(i:Int, v:Dynamic):Void this[i] = v;
}
