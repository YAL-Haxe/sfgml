package sf.gml;
import haxe.DynamicAccess;
import haxe.Int64;
import haxe.Json;
import haxe.ds.ObjectMap;
using StringTools;
using sf.gml.SfYyJsonPrinter.SfYyJsonPrinterTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SfYyJsonPrinter {
	static var isExt:Bool = false;
	static var wantCompact:Bool = false;
	static var trailingCommas:Bool = false;
	static function stringify_string(s:String):String {
		var r = '"';
		var start = 0;
		for (i in 0 ... s.length) {
			var esc:String;
			switch (StringTools.fastCodeAt(s, i)) {
				case '"'.code: esc = '\\"';
				case '/'.code: esc = isExt ? "/" : '\\/';
				case '\\'.code: esc = '\\\\';
				case '\n'.code: esc = '\\n';
				case '\r'.code: esc = '\\r';
				case '\t'.code: esc = '\\t';
				case 8: esc = '\\b';
				case 12: esc = '\\f';
				default: esc = null;
			}
			if (esc != null) {
				if (i > start) {
					r += s.substring(start, i) + esc;
				} else r += esc;
				start = i + 1;
			}
		}
		if (start == 0) return '"$s"';
		if (start < s.length) {
			return r + s.substring(start) + '"';
		} else return r + '"';
	}
	
	public static var mvcOrder22 = ["configDeltas", "id", "modelName", "mvc", "name"];
	public static var mvcOrder23 = ["parent", "resourceVersion", "name", "path", "tags", "resourceType"];
	public static var orderByModelName:Map<String, Array<String>> = (function() {
		var q = new Map();
		var plain = ["id", "modelName", "mvc"];
		q["GMExtensionFunction"] = plain.concat([]);
		q["GMEvent"] = plain.concat(["IsDnD"]);
		return q;
	})();
	public static var metaByModelName:Map<String, SfYyJsonMeta> = @:privateAccess SfYyJsonMeta.initByModelName();
	public static var metaByResourceType:Map<String, SfYyJsonMeta> = @:privateAccess SfYyJsonMeta.initByResourceType();
	
	static var isOrderedCache:Map<Array<String>, Map<String, Bool>> = new Map();
	
	static function fieldComparator(a:String, b:String):Int {
		return a > b ? 1 : -1;
	}
	
	static var indentString:String = "    ";
	static var nextType:String = null;
	static function stringify_rec(obj:Dynamic, indent:Int, compact:Bool, ?digits:Int):String {
		var nt:String = nextType; nextType = null;
		if (obj == null) { // also hits "undefined"
			return "null";
		}
		else if (Std.is(obj, String)) {
			return stringify_string(obj);
		}
		else if (Std.is(obj, Array)) {
			var indentString = SfYyJsonPrinter.indentString;
			var arr:Array<Dynamic> = obj;
			var len = arr.length;
			var wantedCompact = SfYyJsonPrinter.wantCompact;
			if (len == 0 && wantedCompact) return "[]";
			var r = "[\r\n" + indentString.repeat(++indent);
			for (i in 0 ... arr.length) {
				nextType = nt;
				if (wantedCompact) {
					if (i > 0) r += "\r\n" + indentString.repeat(indent);
					r += stringify_rec(arr[i], indent, true) + ",";
				} else {
					if (i > 0) r += ",\r\n" + indentString.repeat(indent);
					r += stringify_rec(arr[i], indent, compact);
				}
			}
			return r + "\r\n" + indentString.repeat(--indent) + "]";
		}
		else if (Reflect.isObject(obj)) {
			if (Int64.isInt64(obj)) return "" + (obj:Int64);
			var indentString = SfYyJsonPrinter.indentString;
			indent += 1;
			var r = (compact ? "{" : "{\r\n" + indentString.repeat(indent));
			var orderedFields:Array<String> = Reflect.field(obj, "hxOrder");
			var fieldDigits:Map<String, Int> = null;
			var fieldTypes:Map<String, String> = null;
			var orderedFieldsFirst = true;
			var found = 0, sep = false;
			// where available, use 
			var meta:SfYyJsonMeta;
			if (nt != null) {
				meta = isExt ? metaByResourceType[nt] : metaByModelName[nt];
				if (meta == null) trace('Unknown type $nt');
			} else if (isExt) {
				nt = obj.resourceType;
				meta = nt != null ? metaByResourceType[nt] : null;
			} else {
				nt = obj.modelName;
				meta = nt != null ? metaByModelName[nt] : null;
			}
			if (meta != null) {
				orderedFields = meta.order;
				fieldTypes = meta.types;
				fieldDigits = meta.digits;
			} else if (orderedFields == null) {
				if (Reflect.hasField(obj, "mvc")) {
					orderedFields = orderByModelName[obj.modelName];
				}
				if (orderedFields == null) {
					orderedFields = isExt ? mvcOrder23 : mvcOrder22;
				}
			} else if (Reflect.hasField(obj, "mvc") || Reflect.hasField(obj, "resourceType")) found++;
			//
			var isOrdered:Map<String, Bool> = isOrderedCache[orderedFields];
			if (isOrdered == null) {
				isOrdered = new Map();
				isOrdered["hxOrder"] = true;
				isOrdered["hxDigits"] = true;
				for (field in orderedFields) isOrdered[field] = true;
				isOrderedCache[orderedFields] = isOrdered;
			}
			//
			var tcs = trailingCommas;
			var orderedFieldsAfter = isExt;
			inline function addSep():Void {
				if (!tcs) {
					if (sep) r += ",\r\n" + indentString.repeat(indent); else sep = true;
				} else if (!compact) {
					if (sep) r += "\r\n" + indentString.repeat(indent); else sep = true;
				}
			}
			inline function addField(field:String):Void {
				addSep();
				found++;
				r += stringify_string(field) + (compact ? ":" : ": ");
				nextType = fieldTypes != null ? fieldTypes[field] : null;
				r += stringify_rec(Reflect.field(obj, field), indent, compact,
					fieldDigits != null ? fieldDigits[field] : null
				);
				if (tcs) r += ",";
			}
			//
			var r0:String, r1:String;
			if (orderedFieldsAfter) {
				r0 = r; r = "";
			} else r0 = null;
			//
			for (field in orderedFields) {
				if (!Reflect.hasField(obj, field)) continue;
				addField(field);
			}
			//
			if (orderedFieldsAfter) { r1 = r; r = r0; } else r1 = null;
			//
			var allFields = Reflect.fields(obj);
			if (allFields.length > found) {
				allFields.sort(fieldComparator);
				if (orderedFieldsAfter) sep = false;
				for (field in allFields) {
					if (isOrdered.exists(field)) continue;
					addField(field);
				}
				if (orderedFieldsAfter && r1 != "") {
					addSep();
					r += r1;
				}
			} else {
				if (orderedFieldsAfter) r += r1;
			}
			//
			indent -= 1;
			return r + (compact ? "}" : "\r\n" + indentString.repeat(indent) + "}");
		}
		else {
			if (digits != null && (Std.is(obj, Int) || obj % 1 == 0)) {
				return obj + StringTools.rpad(".", "0", digits + 1);
			} else return Json.stringify(obj);
		}
	}
	
	public static function stringify(obj:Dynamic, extJson:Bool = false):String {
		wantCompact = extJson;
		trailingCommas = extJson;
		isExt = extJson;
		indentString = extJson ? "  " : "    ";
		return stringify_rec(obj, 0, false);
	}
}
class SfYyJsonPrinterTools {
	public static function repeat(s:String, n:Int):String {
		if (n == 0) return "";
		var len = s.length * n;
		n = Math.floor(Math.log(n) / Math.log(2));
		while (--n >= 0) s += s;
		s += s.substring(0, len - s.length);
		return s;
	}
}