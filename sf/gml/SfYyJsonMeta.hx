package sf.gml;
import haxe.DynamicAccess;

/**
 * ...
 * @author YellowAfterlife
 */
@:forward abstract SfYyJsonMeta(SfYyJsonMetaImpl) from SfYyJsonMetaImpl {
	static function objectToStringMap(o:DynamicAccess<String>):Map<String, String> {
		var m = new Map();
		for (k => v in o) {
			if (Std.is(v, String)) {
				m[k] = v;
			} else throw 'Invalid value type for $k=>$v:' + Type.typeof(v);
		}
		return m;
	}
	static function objectToIntMap(o:DynamicAccess<Int>):Map<String, Int> {
		var m = new Map();
		for (k => v in o) {
			if (Std.is(v, Int)) {
				m[k] = v;
			} else throw 'Invalid value type for $k=>$v:' + Type.typeof(v);
		}
		return m;
	}
	static function keysToIntMap(keys:Array<String>, val:Int):Map<String, Int> {
		var m = new Map();
		for (k in keys) m[k] = val;
		return m;
	}
	static function initByModelName():Map<String, SfYyJsonMeta> {
		var q = new Map<String, SfYyJsonMeta>();
		var base = ["configDeltas", "id", "modelName", "mvc", "name"];
		//
		inline function tt(o:Dynamic):Map<String, String> return objectToStringMap(o);
		inline function td(o:Dynamic):Map<String, Int> return objectToIntMap(o);
		//
		// not used at this time
		//
		return q;
	}
	static function initByResourceType():Map<String, SfYyJsonMeta> {
		var q = new Map<String, SfYyJsonMeta>();
		var base = ["parent", "resourceVersion", "name", "tags", "resourceType"];
		//
		inline function tt(o:Dynamic):Map<String, String> return objectToStringMap(o);
		inline function td(o:Dynamic):Map<String, Int> return objectToIntMap(o);
		function td1(fields:Array<String>):Map<String, Int> {
			return keysToIntMap(fields, 1);
		}
		//
		q["GMExtensionFunction"] = {
			order: ["externalName", "kind", "help", "hidden", "returnType", "argCount", "args"].concat(base)
		}
		q["GMExtensionConstant"] = {
			order: ["value", "hidden"].concat(base)
		}
		//
		return q;
	}
}

typedef SfYyJsonMetaImpl = {
	?order:Array<String>,
	/**
	 * field name -> field resource type
	 * note: for arrays, sets type for contents
	 */
	?types:Map<String, String>,
	/** field name -> digits for numeric output */
	?digits:Map<String, Int>,
};