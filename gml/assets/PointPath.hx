package gml.assets;

@:native("path") @:final @:std @:snakeCase
extern class PointPath extends Asset {
	static inline var defValue:PointPath = cast -1;
	//
	@:native("exists") static function isValid(q:PointPath):Bool;
	//
	static inline function fromIndex(i:Int):PointPath return cast i;
	
	//
	var index(get, never):Int;
	private inline function get_index():Int return cast this;
	//
	var name(get, never):String;
	private function get_name():String;
	//
	var pointCount(get, never):Int;
	@:native("get_number") private function get_pointCount():Int;
	//
	var pixelLength(get, never):Int;
	@:native("get_length") private function get_pixelLength():Int;
	
	//
	var closed(get, set):Bool;
	private function get_closed():Bool;
	@:native("set_closed") private function set_closed_impl(z:Bool):Void;
	private inline function set_closed(z:Bool):Bool {
		set_closed_impl(z);
		return z;
	}
	
	//
	var smooth(get, set):Bool;
	@:native("get_kind") private function get_smooth():Bool;
	@:native("set_kind") private function set_smooth_impl(z:Bool):Void;
	private inline function set_smooth(z:Bool):Bool {
		set_smooth_impl(z);
		return z;
	}
	
	//
	var precision(get, set):Int;
	private function get_precision():Int;
	@:native("set_precision") private function set_precision_impl(z:Int):Void;
	private inline function set_precision(z:Int):Int {
		set_precision_impl(z);
		return z;
	}
	
	//
	@:native("add") function new();
	@:native("delete") function destroy():Void;
	function duplicate():PointPath;
	function append(otherPath:PointPath):Void;
	function assign(to:PointPath):Void;
	//
	function addPoint(x:Float, y:Float, speed:Float):Void;
	function changePoint(index:Int, x:Float, y:Float, speed:Float):Void;
	function insertPoint(beforeIndex:Int, x:Float, y:Float, speed:Float):Void;
	function deletePoint(index:Int):Void;
	function getPointSpeed(index:Int):Float;
	function getPointX(index:Int):Float;
	function getPointY(index:Int):Float;
	//
	function clearPoints():Void;
	function flip():Void;
	function mirror():Void;
	function rescale(xscale:Float, yscale:Float):Void;
	function reverse():Void;
	function rotate(angle:Float):Void;
	function shift(xshift:Float, yshift:Float):Void;
}
