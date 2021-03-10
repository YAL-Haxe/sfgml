package gml.internal;
import SfTools.raw;
import gml.Lib;
import gml.NativeArray;
import gml.ds.ArrayList;

/**
 * Processed and DCE-d by SfGml_ArrayImpl.
 * @author YellowAfterlife
 */
@:std @:keep class ArrayImpl {
	extern private static inline var modernOnly:String = "This method is only available in GMS>=2.3.";
	
	#if !sfgml.modern
	public static function resize<T>(arr:Array<T>, len:Int):Void {
		var olen = arr.length;
		if (len < olen) throw "GML arrays cannot be shrunk in pre-2.3";
		if (len > olen) arr[len - 1] = cast 0;
	}
	#end
	
	//{ insertion
	public static function push<T>(arr:Array<T>, val:T):Int {
		var i:Int = arr.length;
		arr[i] = val;
		return i;
	}
	public static function unshift<T>(arr:Array<T>, val:T):Void {
		var n:Int = arr.length;
		while (n > 0) {
			arr[n] = arr[n - 1];
			n--;
		}
		arr[0] = val;
	}
	public static function insert<T>(arr:Array<T>, pos:Int, val:T):Void {
		var len:Int = arr.length;
		if (pos < 0) {
			pos += len;
			if (pos < 0) pos = 0;
		} else if (pos > len) {
			pos = len;
		}
		// note: unsafe to use array_copy here because order is not specified.
		while (len > pos) {
			arr[len] = arr[len - 1];
			len -= 1;
		}
		arr[pos] = val;
	}
	//}
	
	//{ removal
	public static function pop<T>(arr:Array<T>):Null<T> {
		#if sfgml.modern
		var n = arr.length - 1;
		if (n < 0) return null;
		var r = arr[n];
		arr.resize(n);
		return r;
		#else
		throw modernOnly;
		#end
	}
	public static function shift<T>(arr:Array<T>):Null<T> {
		#if sfgml.modern
		var n = arr.length - 1;
		if (n < 0) return null;
		var r = arr[0];
		var i = -1;
		while (++i < n) {
			arr[i] = arr[i + 1];
		}
		arr.resize(n);
		return r;
		#else
		throw modernOnly;
		#end
	}
	public static function remove<T>(arr:Array<T>, v:T):Bool {
		#if sfgml.modern
		var i = -1;
		var n = arr.length;
		while (++i < n) {
			if (arr[i] == v) {
				#if (sfgml_version >= "2.3.1")
				NativeArray.delete(arr, i, 1);
				#else
				while (++i < n) {
					arr[i - 1] = arr[i];
				}
				arr.resize(n - 1);
				#end
				return true;
			}
		}
		return false;
		#else
		throw modernOnly;
		#end
	}
	public static function splice<T>(arr:Array<T>, pos:Int, len:Int):Array<T> {
		#if sfgml.modern
		if (pos < 0) {
			pos += arr.length;
			if (pos < 0) pos = 0;
		}
		var n = arr.length;
		if (pos + len > n) len = n - pos;
		if (len <= 0) return [];
		var r:Array<T> = NativeArray.createEmpty(len);
		NativeArray.copyPart(r, 0, arr, pos, len);
		#if (sfgml_version >= "2.3.1")
		NativeArray.delete(arr, pos, len);
		#else
		pos += len;
		while (pos < n) {
			arr[pos - len] = arr[pos];
			pos += 1;
		}
		arr.resize(n - len);
		#end
		return r;
		#else
		throw modernOnly;
		#end
	}
	//}
	
	//{
	public static function indexOf<T>(arr:Array<T>, v:T, i:Int = 0):Int {
		var len:Int = arr.length;
		if (i < 0) {
			i += len;
			if (i < 0) i = 0;
		}
		while (i < len) {
			if (arr[i] == v) return i;
			i++;
		}
		return -1;
	}
	public static function lastIndexOf<T>(arr:Array<T>, v:T, i:Int = -1):Int {
		var len:Int = arr.length;
		if (i < 0) i += len;
		else if (i >= len) i = len - 1;
		while (i >= 0) {
			if (arr[i] == v) return i;
			i--;
		}
		return -1;
	}
	//}
	
	//{
	public static function concat<T>(arr1:Array<T>, arr2:Array<T>):Array<T> {
		var len1 = arr1.length;
		var len2 = arr2.length;
		var out:Array<T>;
		if (len1 > 0) {
			#if (sfgml_copyset)
			out = arr1;
			NativeArray.copyset(out, 0, arr1[0]);
			#else
			out = NativeArray.createEmpty(len1);
			NativeArray.copyPart(out, 0, arr1, 0, len1);
			#end
			if (len2 > 0) NativeArray.copyPart(out, len1, arr2, 0, len2);
		} else if (len2 > 0) {
			#if (sfgml_copyset)
			out = arr2;
			NativeArray.copyset(out, 0, arr2[0]);
			#else
			out = NativeArray.createEmpty(len2);
			NativeArray.copyPart(out, 0, arr2, 0, len2);
			#end
		} else out = [];
		return out;
	}
	
	public static function concatFront<T>(arr:Array<T>, item:T):Array<T> {
		if (NativeType.isArray(arr)) return [item];
		var n = NativeArray.length1d(arr);
		var res = NativeArray.createEmpty(1 + n);
		res[0] = item;
		NativeArray.copyPart(res, 1, arr, 0, n);
		return res;
	}
	
	private static var join_buf:gml.io.Buffer = null;
	public static function join<T>(arr:Array<T>, sep:String):String {
		var len = arr.length;
		if (len == 0) return "";
		//
		var buf = join_buf;
		if (buf == null) {
			buf = new gml.io.Buffer(1024, Grow, 1);
			join_buf = buf;
		}
		buf.rewind();
		//
		buf.writeChars(Std.string(arr[0]));
		for (i in 1 ... len) {
			buf.writeChars(sep);
			buf.writeChars(Std.string(arr[i]));
		}
		//
		buf.writeByte(0);
		buf.rewind();
		return buf.readString();
	}
	//}
	
	//{
	public static function reverse<T>(arr:Array<T>) {
		var a:Int = 0;
		var b:Int = arr.length;
		while (a < --b) {
			var c:T = arr[a];
			arr[a++] = arr[b];
			arr[b] = c;
		}
	}
	public static function slice<T>(arr:Array<T>, pos:Int, ?end:Int):Array<T> {
		var len = arr.length;
		if (pos < 0) {
			pos += len;
			if (pos < 0) pos = 0;
		}
		if (end == null || end > len) end = len;
		var len = end - pos;
		var out = NativeArray.createEmpty(len);
		NativeArray.copyPart(out, 0, arr, pos, len);
		return out;
	}
	public static function copy<T>(arr:Array<T>):Array<T> {
		var out:Array<T>;
		var len = arr.length;
		if (len > 0) {
			#if (sfgml_copyset)
			out = arr;
			NativeArray.copyset(out, 0, arr[0]);
			#else
			out = NativeArray.createEmpty(len);
			NativeArray.copyPart(out, 0, arr, 0, len);
			#end
		} else out = [];
		return out;
	}
	//}
	
	//{
	public static function map<T, S>(arr:Array<T>, fn:T->S):Array<S> {
		var len = arr.length;
		var out = NativeArray.createEmpty(len);
		for (i in 0 ... len) out[i] = fn(arr[i]);
		return out;
	}
	private static var filter_list:ArrayList<Dynamic> = null;
	public static function filter<T>(arr:Array<T>, fn:T->Bool):Array<T> {
		var acc = filter_list;
		if (acc == null) {
			acc = new ArrayList();
			filter_list = acc;
		}
		//
		var len = arr.length;
		var pos = 0;
		while (pos < len) {
			var val = arr[pos];
			if (fn(val)) acc.add(val);
			pos += 1;
		}
		//
		len = acc.length;
		var out = NativeArray.createEmpty(len);
		pos = 0;
		while (pos < len) {
			out[pos] = acc[pos];
			pos += 1;
		}
		//
		acc.clear();
		return out;
	}
	public static function sort<T>(arr:Array<T>, fn:T->T->Int):Void {
		var i = 0;
		var l = arr.length;
		while (i < l) {
			var swap = false;
			var j = 0;
			var max = l - i - 1;
			while (j < max) {
				if (fn(arr[j], arr[j + 1]) > 0) {
					var tmp = arr[j + 1];
					arr[j + 1] = arr[j];
					arr[j] = tmp;
					swap = true;
				}
				j += 1;
			}
			if (!swap) break;
			i += 1;
		}
	}
	//}
}