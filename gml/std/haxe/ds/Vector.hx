package haxe.ds;
import gml.NativeArray;

/**
 * ...
 * @author YellowAfterlife
 */
abstract Vector<T>(VectorData<T>) {
	public inline function new(length:Int) {
		this = NativeArray.create(length, null);
	}
	
	@:op([]) public inline function get(index:Int):T {
		return this[index];
	}
	@:op([]) public inline function set(index:Int, val:T):T {
		this[index] = val;
		return val;
	}
	
	public var length(get, never):Int;
	inline function get_length():Int {
		return this.length;
	}
	
	public static inline function blit<T>(src:Vector<T>, srcPos:Int, dst:Vector<T>, dstPos:Int, len:Int):Void {
		NativeArray.copyPart(dst.toData(), dstPos, src.toData(), srcPos, len);
	}
	
	public inline function toArray():Array<T> {
		return this.copy();
	}
	
	public inline function toData():VectorData<T> {
		return cast this;
	}
	public static inline function fromData<T>(data:VectorData<T>):Vector<T> {
		return cast data;
	}
	
	public static inline function fromArrayCopy<T>(array:Array<T>):Vector<T> {
		return fromData(array.copy());
	}
	public inline function copy():Vector<T> {
		return fromData(this.copy());
	}
	
	public inline function join(sep:String):String {
		return this.join(sep);
	}
	
	public inline function map<S>(f:T->S):Vector<S> {
		return fromData(this.map(f));
	}
	
	public inline function sort(f:T->T->Int):Void {
		this.sort(f);
	}
}
private typedef VectorData<T> = Array<T>;
