package gml;
import SfTools.*;
import haxe.extern.Rest;

/**
 * Exposes GML-specific array functions.
 * @author YellowAfterlife
 */
@:native("array") @:final @:std
extern class NativeArray {
	
	/** Creates an array of given size and fills it with given value */
	@:noUsing static function create<T>(size:Int, val:T):Array<T>;
	
	/**
	 * Same as above, but lets GM select the value (currently 0).
	 * This will eventually (GMS >= 2.3) be faster than normal create(),
	 * and is to be used if you are going to populate it yourself anyway.
	 * @see https://bugs.yoyogames.com/view.php?id=29362
	 */
	#if sfgml.modern
	@:native("create") @:noUsing static function createEmpty<T>(size:Int):Array<T>;
	#else
	@:noUsing static inline function createEmpty<T>(size:Int):Array<T> {
		return create(size, cast 0);
	}
	#end
	
	/** Returns the number of items in the given array */
	#if sfgml.modern
	@:native("length")
	#else
	@:native("length_1d")
	#end
	static function length1d<T>(q:Array<T>):Int;
	
	/** Returns the number of items in given row of an array */
	@:native("length_2d") static function cols2d<T>(q:Array<T>, row:Int):Int;
	
	/** Returns the number of rows in the given array. */
	@:native("height_2d") static function rows2d<T>(q:Array<T>):Int;
	
	/** Produces `array[row, col]`. For cases where expression isn't simple, use wget2d */
	static inline function get2d<T>(q:Array<T>, row:Int, col:Int):T {
		return raw("{0}[{1}, {2}]", q, row, col);
	}
	
	/** Produces a call to internal array_get_2D funcion (used for `[@i,k]` accessor) */
	@:native("get_2D") static function wget2d<T>(q:Array<T>, row:Int, col:Int):T;
	
	/** Uses the copy-on-write behaviour to copy arrays or allocate new arrays. */
	static inline function copyset<T>(q:Array<T>, index:Int, value:T):Void {
		#if (!macro && js)
		js.Syntax.code("{0}[{1}] = {2}", q, index, value);
		#end
	}
	
	/** Produces `array[row, col] = value` for copy-on-write behaviour */
	static inline function copyset2d<T>(q:Array<T>, row:Int, col:Int, val:T):Void {
		raw("{0}[{1}, {2}] = {3}", q, row, col, val);
	}
	
	/** Produces a call to internal array_set_2d function (used for `[@i,k]` accessor) */
	@:native("set_2D") static function set2d<T>(q:Array<T>, row:Int, col:Int, val:T):Void;
	
	/** Copies a region from one array to other array. */
	@:native("copy") static function copyPart<T>(
		arr:Array<T>, idx:Int, src:Array<T>, srcIdx:Int, len:Int
	):Void;
	
	static function equals<T>(a:Array<T>, b:Array<T>):Bool;
	
	/** GMS 2.3+ */
	static function delete<T>(arr:Array<T>, index:Int, count:Int):Void;
	
	/** GMS 2.3+ */
	static function insert<T>(arr:Array<T>, index:Int, values:Rest<T>):Void;
	
	/** GMS 2.3+ */
	@:native("sort") static function sortSimple<T>(arr:Array<T>, ascend:Bool):Void;
	
	/** GMS 2.3+ */
	static function sort<T>(arr:Array<T>, comparator:T->T->Int):Void;
	
	/** GMS 2.3+ */
	static function pop<T>(arr:Array<T>):Null<T>;
	
	/** GM2024+ */
	static function shift<T>(arr:Array<T>):Null<T>;
	
	/** GM2024+ */
	static function union<T>(array:Array<T>, arrays:Rest<Array<T>>):Array<T>;
}
