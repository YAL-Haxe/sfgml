package gml;
import gml.assets.Room;
import gml.Lib.raw as raw;
import gml.ds.Color;
import gml.gpu.Camera;
import gml.rooms.ViewIndex;
/**
 * Pending deprecation
 * @author YellowAfterlife
 */
@:std @:native("")
extern class Current {
	/** The current active room (as resource). */
	public static var room:Room;
	
	/** Current room' width (in pixels) */
	@:native("room_width") public static var width:Int;
	
	/** Current room' height (in pixels) */
	@:native("room_height") public static var height:Int;
	
	/** Target framerate for the current room. */
	@:native("room_speed") public static var frameRate:Int;
	
	/** A pseudoarray containing current room' view information. */
	static var views(get, never):ViewIndexes;
	private static inline function get_views():ViewIndexes return null;
	
	@:native("background_color") public static var backgroundColor:Color;
	
	#if !sfgml_next
	static var backgrounds(get, never):BackgroundIndexes;
	private static inline function get_backgrounds():BackgroundIndexes return null;
	#end
}

#if !sfgml_next // background
private abstract BackgroundIndexes(Dynamic) {
	public var length(get, never):Int;
	private inline function get_length():Int return 8;
	@:arrayAccess public inline function get(i:Int):gml.rooms.BackgroundIndex return i;
}
#end

private abstract ViewIndexes(Dynamic) {
	public var enabled(get, set):Bool;
	private inline function get_enabled():Bool return ViewHelperImpl.enabled;
	private inline function set_enabled(val:Bool):Bool {
		ViewHelperImpl.enabled = val;
		return val;
	}
	
	public var current(get, never):ViewIndex;
	private inline function get_current():ViewIndex return ViewHelperImpl.current;
	
	public var length(get, never):Int;
	private inline function get_length():Int return 8;
	
	@:arrayAccess public inline function get(i:Int):ViewIndex return i;
}
@:std @:native("view")
private extern class ViewHelperImpl {
	public static var current:ViewIndex;
	public static var enabled:Bool;
}
