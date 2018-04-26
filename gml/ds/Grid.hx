package gml.ds;
import gml.Lib.raw;
/**
 * Wraps ds_grid_ functions.
 * @author YellowAfterlife
 */
@:native("ds_grid") @:final
extern class Grid<T> {
	public var width(get, never):Int;
	public var height(get, never):Int;
	public var cols(get, never):Int;
	public var rows(get, never):Int;
	
	public function new(width:Int, height:Int);
	public function destroy():Void;
	/**
	 * Returns whether a particular grid exists.
	 * Note: Will check grid#0 (the earliest-created one) if called on a `null`.
	 */
	public static inline function isValid<T>(grid:Grid<T>):Bool {
		return raw("ds_exists")(grid, raw("ds_type_grid"));
	}
	//
	@:native("width") function get_width():Int;
	@:native("height") function get_height():Int;
	@:native("width") function get_cols():Int;
	@:native("height") function get_rows():Int;
	public function resize(newWidth:Int, newHeight:Int):Void;
	//
	public function clear(value:T):Void;
	public inline function copyFrom(source:Grid<T>):Void {
		raw("ds_grid_copy")(this, source);
	}
	public inline function copyTo(destination:Grid<T>):Void {
		raw("ds_grid_copy")(destination, this);
	}
	//
	public function sort(column:Int, ascending:Bool):Void;
	public function shuffle():Void;
	//
	public function get(x:Int, y:Int):T;
	public function set(x:Int, y:Int, value:T):Void;
	public function add(x:Int, y:Int, value:T):Void;
	@:native("multiply") public function mul(x:Int, y:Int, value:T):Void;
	// region:
	@:native("get_max") public function getRegionMax(x1:Float, y1:Float, x2:Float, y2:Float):T;
	@:native("get_min") public function getRegionMin(x1:Float, y1:Float, x2:Float, y2:Float):T;
	@:native("get_mean") public function getRegionMean(x1:Float, y1:Float, x2:Float, y2:Float):T;
	@:native("get_sum") public function getRegionSum(x1:Float, y1:Float, x2:Float, y2:Float):T;
	@:native("set_region") public function setRegion(x1:Float, y1:Float, x2:Float, y2:Float, value:T):Void;
	@:native("add_region") public function addRegion(x1:Float, y1:Float, x2:Float, y2:Float, value:T):Void;
	@:native("multiply_region") public function mulRegion(x1:Float, y1:Float, x2:Float, y2:Float, value:T):Void;
	// disc:
	@:native("get_disk_max") public function getDiscMax(x:Float, y:Float, radius:Float):T;
	@:native("get_disk_min") public function getDiscMin(x:Float, y:Float, radius:Float):T;
	@:native("get_disk_mean") public function getDiscMean(x:Float, y:Float, radius:Float):T;
	@:native("get_disk_sum") public function getDiscSum(x:Float, y:Float, radius:Float):T;
	@:native("set_disk") public function setDisc(x:Float, y:Float, radius:Float, value:T):Void;
	@:native("add_disk") public function addDisc(x:Float, y:Float, radius:Float, value:T):Void;
	@:native("multiply_disk") public function mulDisc(x:Float, y:Float, radius:Float, value:T):Void;
	// grid:
	public inline function setGridRegion(x:Int, y:Int, source:Grid<T>, sx1:Int, sy1:Int, sx2:Int, sy2:Int):Void {
		raw("ds_grid_set_grid_region")(this, source, sx1, sy1, sx2, sy2, x, y);
	}
	public inline function addGridRegion(x:Int, y:Int, source:Grid<T>, sx1:Int, sy1:Int, sx2:Int, sy2:Int):Void {
		raw("ds_grid_add_grid_region")(this, source, sx1, sy1, sx2, sy2, x, y);
	}
	public inline function mulGridRegion(x:Int, y:Int, source:Grid<T>, sx1:Int, sy1:Int, sx2:Int, sy2:Int):Void {
		raw("ds_grid_mul_grid_region")(this, source, sx1, sy1, sx2, sy2, x, y);
	}
	// search:
	@:native("value_exists") public function valueExists(x1:Float, y1:Float, x2:Float, y2:Float, value:T):Bool;
	@:native("value_x") public function valueX(x1:Float, y1:Float, x2:Float, y2:Float, value:T):Int;
	@:native("value_y") public function valueY(x1:Float, y1:Float, x2:Float, y2:Float, value:T):Int;
	@:native("value_disk_exists") public function valueDiscExists(x:Float, y:Float, radius:Float, value:T):Bool;
	@:native("value_disk_x") public function valueDiscX(x:Float, y:Float, radius:Float, value:T):Int;
	@:native("value_disk_y") public function valueDiscY(x:Float, y:Float, radius:Float, value:T):Int;
	// i/o:
	public function read(from:String):Void;
	public function write():String;
	//
	/*public inline function iterator():GridIterator<T> {
		return new GridIterator<T>(this);
	}*/
}

class GridIterator<T> {
	public var grid:Grid<T>;
	public var col:Int = 0;
	public var row:Int = 0;
	public var cols:Int;
	public var rows:Int;
	public inline function new(grid:Grid<T>) {
		this.grid = grid;
		this.cols = grid.cols;
		this.rows = grid.rows;
	}
	@:runtime @:extern public inline function hasNext():Bool {
		return row < rows;
	}
	@:runtime @:extern public inline function next():T {
		var r = grid.get(col, row);
		if (++col >= cols) {
			col = 0;
			row++;
		}
		return r;
	}
}
