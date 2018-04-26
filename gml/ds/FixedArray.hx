package gml.ds;

/**
 * A wrapper for a single-row ds_grid.
 * Less needed nowadays.
 * @author YellowAfterlife
 */
@:forward(destroy, clear, shuffle)
abstract FixedArray<T>(Grid<T>) from Grid<T> to Grid<T> {
	public inline function new(length:Int) {
		this = new Grid<T>(length, 1);
	}
	public static inline function isValid<T>(arr:FixedArray<T>):Bool {
		return SfTools.raw("ds_exists")(arr, SfTools.raw("ds_type_grid"));
	}
	//{ size
	public var length(get, never):Int;
	private inline function get_length():Int {
		return this.cols;
	}
	public inline function resize(newLength:Int):Void {
		this.resize(newLength, 1);
	}
	//}
	//{ per-cell
	@:arrayAccess public inline function get(index:Int):T {
		return this.get(index, 0);
	}
	public inline function set(index:Int, value:T):Void {
		this.set(index, 0, value);
	}
	@:arrayAccess private inline function arrayWrite(index:Int, value:T):T {
		this.set(index, 0, value);
		return value;
	}
	//
	public inline function add(index:Int, value:T):Void {
		this.add(index, 0, value);
	}
	public inline function mul(index:Int, value:T):Void {
		this.mul(index, 0, value);
	}
	//}
	//{ region
	public inline function setRangeFrom(i:Int, source:FixedArray<T>, i1:Int, i2:Int) {
		this.setGridRegion(i, 0, source, i1, 0, i2, 0);
	}
	public inline function getSum(i1:Int, i2:Int):T {
		return this.getRegionSum(i1, 0, i2, 0);
	}
	//}
}
