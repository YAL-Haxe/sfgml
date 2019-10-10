package sf;

import haxe.Json;
using StringTools;

/**
 * This is pretty much the same as YyJson in GMEdit, but printing to a StringBuf instead.
 * @author YellowAfterlife
 */
class SfYyJson {
	static function stringify_string(b:StringBuf, s:String):Void {
		b.addChar('"'.code);
		var start = 0;
		for (i in 0 ... s.length) {
			var esc:String;
			switch (StringTools.fastCodeAt(s, i)) {
				case '"'.code: esc = '\\"';
				case '/'.code: esc ='\\/';
				case '\\'.code: esc = '\\\\';
				case '\n'.code: esc = '\\n';
				case '\r'.code: esc = '\\r';
				case '\t'.code: esc = '\\t';
				case 8: esc = '\\b';
				case 12: esc = '\\f';
				default: esc = null;
			}
			if (esc != null) {
				if (i > start) b.addSub(s, start, i - start);
				b.add(esc);
				start = i + 1;
			}
		}
		if (start == 0) {
			b.add(s);
		} else if (start < s.length) {
			b.addSub(s, start);
		}
		b.addChar('"'.code);
	}
	
	public static var mvcOrder = ["configDeltas", "id", "modelName", "mvc", "name"];
	public static var orderByModelName:Map<String, Array<String>> = (function() {
		var q = new Map();
		var plain = ["id", "modelName", "mvc"];
		q["GMExtensionFunction"] = plain.concat([]);
		q["GMEvent"] = plain.concat(["IsDnD"]);
		return q;
	})();
	
	static var isOrderedCache:Map<Array<String>, Map<String, Bool>> = new Map();
	
	static function fieldComparator(a:String, b:String):Int {
		return a > b ? 1 : -1;
	}
	
	static inline var indentString:String = "    ";
	static function indentRepeat(indent:Int) {
		var r = "";
		for (_ in 0 ... indent) r += indentString;
		return r;
	}
	static function stringify_rec(b:StringBuf, obj:Dynamic, indent:Int) {
		inline function addIndent(i:Int):Void {
			while (--i >= 0) b.add(indentString);
		}
		if (obj == null) {
			b.add("null");
		}
		else if (Std.is(obj, String)) {
			stringify_string(b, obj);
		}
		else if (Std.is(obj, Array)) {
			var arr:Array<Dynamic> = obj;
			b.add("[\r\n");
			addIndent(++indent);
			for (i in 0 ... arr.length) {
				if (i > 0) {
					b.add(",\r\n");
					addIndent(indent);
				}
				stringify_rec(b, arr[i], indent);
			}
			b.add("\r\n");
			addIndent(--indent);
			b.add("]");
		}
		else if (Reflect.isObject(obj)) {
			b.add("{\r\n");
			addIndent(++indent);
			var orderedFields:Array<String> = Reflect.field(obj, "hxOrder");
			var found = 0, sep = false;
			if (orderedFields == null) {
				if (Reflect.hasField(obj, "mvc")) {
					orderedFields = orderByModelName[Reflect.field(obj, "modelName")];
				}
				if (orderedFields == null) orderedFields = mvcOrder;
			} else found++;
			//
			var isOrdered:Map<String, Bool> = isOrderedCache[orderedFields];
			if (isOrdered == null) {
				isOrdered = new Map();
				isOrdered["hxOrder"] = true;
				for (field in orderedFields) isOrdered[field] = true;
				isOrderedCache[orderedFields] = isOrdered;
			}
			//
			inline function addField(field:String):Void {
				if (sep) {
					b.add(",\r\n");
					addIndent(indent);
				} else sep = true;
				found++;
				stringify_string(b, field);
				b.add(": ");
				stringify_rec(b, Reflect.field(obj, field), indent);
			}
			//
			for (field in orderedFields) {
				if (!Reflect.hasField(obj, field)) continue;
				addField(field);
			}
			//
			var allFields = Reflect.fields(obj);
			if (allFields.length > found) {
				allFields.sort(fieldComparator);
				for (field in allFields) {
					if (isOrdered.exists(field)) continue;
					addField(field);
				}
			}
			b.add("\r\n");
			addIndent(--indent);
			b.add("}");
		}
		else {
			b.add(Json.stringify(obj));
		}
	}
	public static function stringify(obj:Dynamic):String {
		var b = new StringBuf();
		stringify_rec(b, obj, 0);
		return b.toString();
	}
}
