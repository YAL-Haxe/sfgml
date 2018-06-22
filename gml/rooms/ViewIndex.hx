package gml.rooms;
import gml.assets.Object;
import gml.gpu.Camera;
import gml.gpu.Surface;

/**
 * ...
 * @author YellowAfterlife
 */
abstract ViewIndex(Int) from Int to Int {
	
	//
	public var visible(get, set):Bool;
	private inline function get_visible():Bool {
		return ViewImpl.visible[this];
	}
	private inline function set_visible(val:Bool):Bool {
		ViewImpl.visible[this] = val;
		return val;
	}
	
	#if !sfgml_next
	//
	public var x(get, set):Float;
	private inline function get_x():Float {
		return ViewImpl.xview[this];
	}
	private inline function set_x(val:Float):Float {
		ViewImpl.xview[this] = val;
		return val;
	}
	
	//
	public var y(get, set):Float;
	private inline function get_y():Float {
		return ViewImpl.yview[this];
	}
	private inline function set_y(val:Float):Float {
		ViewImpl.yview[this] = val;
		return val;
	}
	
	//
	public var width(get, set):Float;
	private inline function get_width():Float {
		return ViewImpl.wview[this];
	}
	private inline function set_width(val:Float):Float {
		ViewImpl.wview[this] = val;
		return val;
	}
	
	//
	public var height(get, set):Float;
	private inline function get_height():Float {
		return ViewImpl.hview[this];
	}
	private inline function set_height(val:Float):Float {
		ViewImpl.hview[this] = val;
		return val;
	}
	
	//
	public var angle(get, set):Float;
	private inline function get_angle():Float {
		return ViewImpl.angle[this];
	}
	private inline function set_angle(val:Float):Float {
		ViewImpl.angle[this] = val;
		return val;
	}
	
	//
	public var hspeed(get, set):Float;
	private inline function get_hspeed():Float {
		return ViewImpl.hspeed[this];
	}
	private inline function set_hspeed(val:Float):Float {
		ViewImpl.hspeed[this] = val;
		return val;
	}
	
	//
	public var vspeed(get, set):Float;
	private inline function get_vspeed():Float {
		return ViewImpl.vspeed[this];
	}
	private inline function set_vspeed(val:Float):Float {
		ViewImpl.vspeed[this] = val;
		return val;
	}
	
	//
	public var hborder(get, set):Float;
	private inline function get_hborder():Float {
		return ViewImpl.hborder[this];
	}
	private inline function set_hborder(val:Float):Float {
		ViewImpl.hborder[this] = val;
		return val;
	}
	
	//
	public var vborder(get, set):Float;
	private inline function get_vborder():Float {
		return ViewImpl.vborder[this];
	}
	private inline function set_vborder(val:Float):Float {
		ViewImpl.vborder[this] = val;
		return val;
	}
	
	//
	public var target(get, set):ViewTarget;
	private inline function get_target():ViewTarget {
		return ViewImpl.target[this];
	}
	private inline function set_target(val:ViewTarget):ViewTarget {
		ViewImpl.target[this] = val;
		return val;
	}
	#end
	
	#if sfgml_next
	//
	public var camera(get, set):Camera;
	private inline function get_camera():Camera {
		return ViewImpl.camera[this];
	}
	private inline function set_camera(val:Camera):Camera {
		ViewImpl.camera[this] = val;
		return val;
	}
	#end
	
	//
	public var port(get, never):ViewPortIndex;
	private inline function get_port():ViewPortIndex {
		return this;
	}
	
	//
	public var surface(get, set):Surface;
	private inline function get_surface():Surface {
		return ViewImpl.surface[this];
	}
	private inline function set_surface(val:Surface):Surface {
		ViewImpl.surface[this] = val;
		return val;
	}
	
}

typedef ViewTarget = haxe.extern.EitherType<Object, gml.Instance>;

@:keep @:native("view") @:std @:noRefWrite
private extern class ViewImpl {
	public static var visible:Array<Bool>;
	#if !sfgml_next
	public static var xview:Array<Float>;
	public static var yview:Array<Float>;
	public static var wview:Array<Float>;
	public static var hview:Array<Float>;
	public static var angle:Array<Float>;
	public static var hspeed:Array<Float>;
	public static var vspeed:Array<Float>;
	public static var hborder:Array<Float>;
	public static var vborder:Array<Float>;
	@:native("object") public static var target:Array<ViewTarget>;
	#else
	public static var camera:Array<Camera>;
	#end
	public static var xport:Array<Float>;
	public static var yport:Array<Float>;
	public static var wport:Array<Float>;
	public static var hport:Array<Float>;
	@:native("surface_id") public static var surface:Array<Surface>;
}

abstract ViewPortIndex(Int) from Int to Int {
	
	//
	public var x(get, set):Float;
	private inline function get_x():Float {
		return ViewImpl.xport[this];
	}
	private inline function set_x(val:Float):Float {
		ViewImpl.xport[this] = val;
		return val;
	}
	
	//
	public var y(get, set):Float;
	private inline function get_y():Float {
		return ViewImpl.yport[this];
	}
	private inline function set_y(val:Float):Float {
		ViewImpl.yport[this] = val;
		return val;
	}
	
	//
	public var width(get, set):Float;
	private inline function get_width():Float {
		return ViewImpl.wport[this];
	}
	private inline function set_width(val:Float):Float {
		ViewImpl.wport[this] = val;
		return val;
	}
	
	//
	public var height(get, set):Float;
	private inline function get_height():Float {
		return ViewImpl.hport[this];
	}
	private inline function set_height(val:Float):Float {
		ViewImpl.hport[this] = val;
		return val;
	}
}
