package gml;
import gml.assets.Room;
import gml.Lib.raw as raw;
import gml.ds.Color;
/**
 * Pending deprecation
 * @author YellowAfterlife
 */
@:std @:native("")
extern class Current {
	/** The current active room (as resource). */
	public static var room:Room;
	
	/** Current room' width (in pixels) */
	@:native("room_width") public static var width(default, never):Int;
	
	/** Current room' height (in pixels) */
	@:native("room_height") public static var height(default, never):Int;
	
	/** Target framerate for the current room. */
	@:native("room_speed") public static var frameRate:Int;
	
	/** A pseudoarray containing current room' view information. */
	static var views(get, never):ViewArray;
	private static inline function get_views():ViewArray return null;
	
	@:native("background_color") public static var backgroundColor:Color;
}
//{ view_
private abstract View(Int) {
	public inline function new(index:Int) this = index;
	//
	public var visible(get, set):Bool;
	inline function get_visible() return untyped __gml__("view_visible[{0}]", this);
	inline function set_visible(v:Bool) {
		untyped __gml__("view_visible[{0}] = {1}", this, v);
		return v;
	}
	//{
	public var x(get, set):Float;
	inline function get_x() return untyped __gml__("view_xview[{0}]", this);
	inline function set_x(v:Float) {
		untyped __gml__("view_xview[{0}] = {1}", this, v);
		return v;
	}
	public var y(get, set):Float;
	inline function get_y() return untyped __gml__("view_yview[{0}]", this);
	inline function set_y(v:Float) {
		untyped __gml__("view_yview[{0}] = {1}", this, v);
		return v;
	}
	public var width(get, set):Float;
	inline function get_width() return untyped __gml__("view_wview[{0}]", this);
	inline function set_width(v:Float) {
		untyped __gml__("view_wview[{0}] = {1}", this, v);
		return v;
	}
	public var height(get, set):Float;
	inline function get_height() return untyped __gml__("view_hview[{0}]", this);
	inline function set_height(v:Float) {
		untyped __gml__("view_hview[{0}] = {1}", this, v);
		return v;
	}
	public var angle(get, set):Float;
	inline function get_angle() return untyped __gml__("view_angle[{0}]", this);
	inline function set_angle(v) {
		untyped __gml__("view_angle[{0}] = {1}", this, v);
		return v;
	}
	//}
	//{
	public var speed(get, never):ViewSpeed;
	inline function get_speed() return new ViewSpeed(this);
	public var port(get, never):ViewPort;
	inline function get_port() return new ViewPort(this);
	//}
}

private abstract ViewSpeed(Int) {
	public inline function new(index:Int) this = index;
	public var x(get, set):Float;
	inline function get_x() return untyped __gml__("view_hspeed[{0}]", this);
	inline function set_x(v) {
		untyped __gml__("view_hspeed[{0}] = {1}", this, v);
		return v;
	}
	public var y(get, set):Float;
	inline function get_y() return untyped __gml__("view_vspeed[{0}]", this);
	inline function set_y(v) {
		untyped __gml__("view_vspeed[{0}] = {1}", this, v);
		return v;
	}
	public inline function set(xsp:Float, ysp:Float):Void {
		x = xsp;
		y = ysp;
	}
}

private abstract ViewPort(Int) {
	public inline function new(index:Int) this = index;
	public var x(get, set):Float;
	inline function get_x() return untyped __gml__("view_xport[{0}]", this);
	inline function set_x(v) {
		untyped __gml__("view_xport[{0}] = {1}", this, v);
		return v;
	}
	public var y(get, set):Float;
	inline function get_y() return untyped __gml__("view_yport[{0}]", this);
	inline function set_y(v) {
		untyped __gml__("view_yport[{0}] = {1}", this, v);
		return v;
	}
	public var width(get, set):Float;
	inline function get_width() return untyped __gml__("view_wport[{0}]", this);
	inline function set_width(v) {
		untyped __gml__("view_wport[{0}] = {1}", this, v);
		return v;
	}
	public var height(get, set):Float;
	inline function get_height() return untyped __gml__("view_hport[{0}]", this);
	inline function set_height(v) {
		untyped __gml__("view_hport[{0}] = {1}", this, v);
		return v;
	}
}

private abstract ViewArray(Array<View>) {
	public var length(get, never):Int;
	inline function get_length():Int return 8;
	@:arrayAccess inline function get_view(index:Int) return new View(index);
	public inline function iterator() return new ViewIterator();
}

@:arrayClass private class ViewIterator {
	var index:Int;
	public inline function new() index = 0;
	public inline function hasNext():Bool return index < 8;
	public inline function next():View return Current.views[index++];
}
//}
