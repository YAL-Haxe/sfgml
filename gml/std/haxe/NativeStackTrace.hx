package haxe;
import gml.NativeArray;
import gml.NativeType;
import haxe.CallStack;
import haxe.CallStack.StackItem;

/**
 * ...
 * @author YellowAfterlife
 */
@:dox(hide)
@:noCompletion
@:allow(haxe.Exception)
class NativeStackTrace {
	// if I let this be Array<String>, I get "module String does not define type String"
	public static function toHaxe(s:Array<Any>, skip:Int = 0):Array<StackItem> {
		if (!NativeType.isArray(s)) return [];
		var n = s.length;
		var r:Array<StackItem> = NativeArray.createEmpty(n);
		var i = -1;
		while (++i < n) {
			var v = s[i];
			r[i] = StackItem.Module(NativeType.isString(v) ? v : "?");
		}
		return r;
	}
	public static function normalize(s:Any, skipItems:Int = 0):Any {
		if (NativeType.isArray(s)) {
			return (s:Array<StackItem>).slice(skipItems);
		} else return s;
	}
}