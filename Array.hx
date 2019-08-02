package;
import SfTools.raw;
import gml.Lib;
import gml.NativeArray;
import gml.ds.ArrayList;

/**
 * Arrays in GameMaker are ARC[-ish], thus do not need to be disposed manually;
 * Currently arrays cannot be shrinked - use gml.ds.ArrayList if you need that.
 * @author YellowAfterlife
 */
#if !macro
@:std @:native("array") @:final
extern class Array<T> implements ArrayAccess<T> {
	var length(get, never):Int;
	private inline function get_length():Int {
		return raw("array_length_1d")(this);
	}
	
	function new();
	inline function toString():String return raw("string")(this);
	
	inline function push(value:T):Int return ArrayImpl.push(this, value);
	inline function unshift(value:T):Void ArrayImpl.unshift(this, value);
	inline function insert(pos:Int, value:T):Void ArrayImpl.insert(this, pos, value);
	
	inline function indexOf(val:T, i:Int = 0):Int return ArrayImpl.indexOf(this, val, i);
	inline function lastIndexOf(val:T, i:Int = -1):Int return ArrayImpl.lastIndexOf(this, val, i);
	
	inline function concat(arr:Array<T>):Array<T> return ArrayImpl.concat(this, arr);
	inline function join(sep:String):String return ArrayImpl.join(this, sep);
	
	inline function reverse():Void ArrayImpl.reverse(this);
	inline function slice(pos:Int, ?end:Int):Array<T> return ArrayImpl.slice(this, pos, end);
	inline function copy():Array<T> return ArrayImpl.copy(this);
	
	inline function sort(fn:T->T->Int):Void ArrayImpl.sort(this, fn);
	inline function map<S>(fn:T->S):Array<S> return ArrayImpl.map(this, fn);
	inline function filter(fn:T->Bool):Array<T> return ArrayImpl.filter(this, fn);
	
	inline function resize(len:Int):Void ArrayImpl.resize(this, len);
	
	//{
	/** Array.pop cannot be implemented because GML arrays cannot be contracted */
	@:extern public inline function pop():Null<T> {
		throw "Array.pop is not supported.";
	}
	
	/** Array.shift cannot be implemented because GML arrays cannot be contracted */
	@:extern public inline function shift():Null<T> {
		throw "Array.shift is not supported.";
	}
	
	/** Array.remove cannot be implemented because GML arrays cannot be contracted */
	@:extern public inline function remove(v:T):Bool {
		throw "Array.remove is not supported.";
	}
	
	/** Array.splice cannot be implemented because GML arrays cannot be contracted */
	@:extern public inline function splice(pos:Int, len:Int):Array<T> {
		throw "Array.splice is not supported";
	}
	//}
	
	inline function iterator():Iterator<T> {
		return new ArrayIterator(this);
	}
}
@:native("array_hx_iterator")
@:nativeGen private class ArrayIterator<T> {
	public function new(arr:Array<T>) {
		this.array = arr;
		this.index = 0;
	}
	public dynamic function hasNext():Bool {
		return index < array.length;
	}
	public dynamic function next():T {
		return array[index++];
	}
	public var array:Array<T>;
	public var index:Int;
}
@:std @:native("array_hx") @:noCompletion
class ArrayImpl {
	public static function resize<T>(arr:Array<T>, len:Int):Void {
		var olen = arr.length;
		if (len < olen) throw "GML arrays cannot be shrunk";
		if (len > olen) arr[len - 1] = cast 0;
	}
	
	//{
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
	
	//{
	public static function indexOf<T>(arr:Array<T>, v:T, i:Int):Int {
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
			out = [];
			NativeArray.copyPart(out, 0, arr1, 0, len1);
			#end
			if (len2 > 0) NativeArray.copyPart(out, len1, arr2, 0, len2);
		} else if (len2 > 0) {
			#if (sfgml_copyset)
			out = arr2;
			NativeArray.copyset(out, 0, arr2[0]);
			#else
			out = [];
			NativeArray.copyPart(out, 0, arr2, 0, len2);
			#end
		} else out = [];
		return out;
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
		var out = NativeArray.create(len);
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
			out = [];
			NativeArray.copyPart(out, 0, arr, 0, len);
			#end
		} else out = [];
		return out;
	}
	//}
	
	//{
	public static function map<T, S>(arr:Array<T>, fn:T->S):Array<S> {
		var len = arr.length;
		var out = NativeArray.create(len);
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
		var out = NativeArray.create(len);
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
#else
// exact copy of std Array.hx
extern class Array<T> {

	/**
		The length of `this` Array.
	**/
	var length(default,null) : Int;

	/**
		Creates a new Array.
	**/
	function new() : Void;

	/**
		Returns a new Array by appending the elements of `a` to the elements of
		`this` Array.

		This operation does not modify `this` Array.

		If `a` is the empty Array `[]`, a copy of `this` Array is returned.

		The length of the returned Array is equal to the sum of `this.length`
		and `a.length`.

		If `a` is `null`, the result is unspecified.
	**/
	function concat( a : Array<T> ) : Array<T>;

	/**
		Returns a string representation of `this` Array, with `sep` separating
		each element.

		The result of this operation is equal to `Std.string(this[0]) + sep +
		Std.string(this[1]) + sep + ... + sep + Std.string(this[this.length-1])`

		If `this` is the empty Array `[]`, the result is the empty String `""`.
		If `this` has exactly one element, the result is equal to a call to
		`Std.string(this[0])`.

		If `sep` is null, the result is unspecified.
	**/
	function join( sep : String ) : String;

	/**
		Removes the last element of `this` Array and returns it.

		This operation modifies `this` Array in place.

		If `this` has at least one element, `this.length` will decrease by 1.

		If `this` is the empty Array `[]`, null is returned and the length
		remains 0.
	**/
	function pop() : Null<T>;

	/**
		Adds the element `x` at the end of `this` Array and returns the new
		length of `this` Array.

		This operation modifies `this` Array in place.

		`this.length` increases by 1.
	**/
	function push(x : T) : Int;

	/**
		Reverse the order of elements of `this` Array.

		This operation modifies `this` Array in place.

		If `this.length < 2`, `this` remains unchanged.
	**/
	function reverse() : Void;

	/**
		Removes the first element of `this` Array and returns it.

		This operation modifies `this` Array in place.

		If `this` has at least one element, `this`.length and the index of each
		remaining element is decreased by 1.

		If `this` is the empty Array `[]`, `null` is returned and the length
		remains 0.
	**/
	function shift() : Null<T>;

	/**
		Creates a shallow copy of the range of `this` Array, starting at and
		including `pos`, up to but not including `end`.

		This operation does not modify `this` Array.

		The elements are not copied and retain their identity.

		If `end` is omitted or exceeds `this.length`, it defaults to the end of
		`this` Array.

		If `pos` or `end` are negative, their offsets are calculated from the
		end of `this` Array by `this.length + pos` and `this.length + end`
		respectively. If this yields a negative value, 0 is used instead.

		If `pos` exceeds `this.length` or if `end` is less than or equals
		`pos`, the result is `[]`.
	**/
	function slice( pos : Int, ?end : Int ) : Array<T>;

	/**
		Sorts `this` Array according to the comparison function `f`, where
		`f(x,y)` returns 0 if x == y, a positive Int if x > y and a
		negative Int if x < y.

		This operation modifies `this` Array in place.

		The sort operation is not guaranteed to be stable, which means that the
		order of equal elements may not be retained. For a stable Array sorting
		algorithm, `haxe.ds.ArraySort.sort()` can be used instead.

		If `f` is null, the result is unspecified.
	**/
	function sort( f : T -> T -> Int ) : Void;

	/**
		Removes `len` elements from `this` Array, starting at and including
		`pos`, an returns them.

		This operation modifies `this` Array in place.

		If `len` is < 0 or `pos` exceeds `this`.length, an empty Array [] is 
		returned and `this` Array is unchanged.

		If `pos` is negative, its value is calculated from the end	of `this`
		Array by `this.length + pos`. If this yields a negative value, 0 is
		used instead.

		If the sum of the resulting values for `len` and `pos` exceed
		`this.length`, this operation will affect the elements from `pos` to the
		end of `this` Array.

		The length of the returned Array is equal to the new length of `this`
		Array subtracted from the original length of `this` Array. In other
		words, each element of the original `this` Array either remains in
		`this` Array or becomes an element of the returned Array.
	**/
	function splice( pos : Int, len : Int ) : Array<T>;

	/**
		Returns a string representation of `this` Array.

		The result will include the individual elements' String representations
		separated by comma. The enclosing [ ] may be missing on some platforms,
		use `Std.string()` to get a String representation that is consistent
		across platforms.
	**/
	function toString() : String;

	/**
		Adds the element `x` at the start of `this` Array.

		This operation modifies `this` Array in place.

		`this.length` and the index of each Array element increases by 1.
	**/
	function unshift( x : T ) : Void;

	/**
		Inserts the element `x` at the position `pos`.

		This operation modifies `this` Array in place.

		The offset is calculated like so:

		- If `pos` exceeds `this.length`, the offset is `this.length`.
		- If `pos` is negative, the offset is calculated from the end of `this`
		  Array, i.e. `this.length + pos`. If this yields a negative value, the
		  offset is 0.
		- Otherwise, the offset is `pos`.

		If the resulting offset does not exceed `this.length`, all elements from
		and including that offset to the end of `this` Array are moved one index
		ahead.
	**/
	function insert( pos : Int, x : T ) : Void;

	/**
		Removes the first occurrence of `x` in `this` Array.

		This operation modifies `this` Array in place.

		If `x` is found by checking standard equality, it is removed from `this`
		Array and all following elements are reindexed accordingly. The function
		then returns true.

		If `x` is not found, `this` Array is not changed and the function
		returns false.
	**/
	function remove( x : T ) : Bool;

	/**
		Returns position of the first occurrence of `x` in `this` Array, searching front to back.

		If `x` is found by checking standard equality, the function returns its index.

		If `x` is not found, the function returns -1.

		If `fromIndex` is specified, it will be used as the starting index to search from,
		otherwise search starts with zero index. If it is negative, it will be taken as the
		offset from the end of `this` Array to compute the starting index. If given or computed
		starting index is less than 0, the whole array will be searched, if it is greater than
		or equal to the length of `this` Array, the function returns -1.
	**/
	function indexOf( x : T, ?fromIndex:Int ) : Int;

	/**
		Returns position of the last occurrence of `x` in `this` Array, searching back to front.

		If `x` is found by checking standard equality, the function returns its index.

		If `x` is not found, the function returns -1.

		If `fromIndex` is specified, it will be used as the starting index to search from,
		otherwise search starts with the last element index. If it is negative, it will be
		taken as the offset from the end of `this` Array to compute the starting index. If
		given or computed starting index is greater than or equal to the length of `this` Array,
		the whole array will be searched, if it is less than 0, the function returns -1.
	**/
	function lastIndexOf( x : T, ?fromIndex:Int ) : Int;

	/**
		Returns a shallow copy of `this` Array.

		The elements are not copied and retain their identity, so
		`a[i] == a.copy()[i]` is true for any valid `i`. However,
		`a == a.copy()` is always false.
	**/
	function copy() : Array<T>;

	/**
		Returns an iterator of the Array values.
	**/
	function iterator() : Iterator<T>;

	/**
		Creates a new Array by applying function `f` to all elements of `this`.

		The order of elements is preserved.

		If `f` is null, the result is unspecified.
	**/
	function map<S>( f : T -> S ) : Array<S>;

	/**
		Returns an Array containing those elements of `this` for which `f`
		returned true.

		The individual elements are not duplicated and retain their identity.

		If `f` is null, the result is unspecified.
	**/
	function filter( f : T -> Bool ) : Array<T>;

	/**
		Set the length of the Array.

		If `len` is shorter than the array's current size, the last
		`length - len` elements will be removed. If `len` is longer, the Array
		will be extended, with new elements set to a target-specific default
		value:

		- always null on dynamic targets
		- 0, 0.0 or false for Int, Float and Bool respectively on static targets
		- null for other types on static targets
	**/
	function resize( len : Int ) : Void;
}
#end
