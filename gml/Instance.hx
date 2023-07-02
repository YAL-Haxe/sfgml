package gml;
import gml.assets.*;
import SfTools.raw;
import haxe.extern.EitherType;

/**
 * Represents an instance of a GameMaker object.
 * Filed access will use .field syntax on these and untyped field access is allowed.
 * Object wrappers should inherit from this, setting `@:object("obj_name")`
 * @author YellowAfterlife
 */
@:std @:native("instance") @:object("obj_blank")
extern class Instance {
	static inline var defValue:Instance = cast -4;
	//
	#if (sfgml_next)
	@:expose("instance_create_depth")
	static function createAtDepth(x:Float, y:Float, depth:Float, t:Object, ?varStruct:Any):Instance;
	
	@:expose("instance_create_layer")
	static function createAtLayer(x:Float, y:Float, layer:gml.layers.LayerID, t:Object, ?varStruct:Any):Instance;
	#else
	static function create(x:Float, y:Float, t:Object):Instance;
	#end
	
	#if (sfgml_version && sfgml_version < "1.4.1763")
	inline function destroy():Void {
		Syntax.code("with ({0}) instance_destroy()", this);
	}
	#else
	@:expose("instance_destroy")
	function destroy(?performDestroyEvent:Bool):Void;
	#end
	
	//
	static function exists(inst:Instance):Bool;
	@:native("number") static function count(type:EitherType<Object, Class<Instance>>):Int;
	static inline function fromId(id:Int):Instance return cast id;
	
	//
	@:expose("instance_copy") function copy(performCreate:Bool):Instance;
	
	inline function changeType(newType:Object, performEvents:Bool):Void {
		raw("with ({0}) instance_change({1}, {2})", this, newType, performEvents);
	}
	
	//
	var id(default, never):Int;
	var object_index(default, set):Object;
	private inline function set_object_index(o:Object):Object {
		raw("with ({0}) instance_change({1}, {2})", this, o, false);
		return o;
	}
	//
	@:expose("variable_instance_exists") function hasField(fd:String):Bool;
	@:expose("variable_instance_get") function getField(fd:String):Dynamic;
	@:expose("variable_instance_set") function setField(fd:String, val:Dynamic):Void;
	@:expose("variable_instance_get_names") function getFieldNames():Array<String>;
	//
	var x:Float;
	var xprevious:Float;
	var xstart:Float;
	var y:Float;
	var yprevious:Float;
	var ystart:Float;
	//
	var alarm(get, never):InstanceAlarms;
	private inline function get_alarm():InstanceAlarms {
		return new InstanceAlarms(this);
	}
	//
	var speed:Float;
	var direction:Float;
	var hspeed:Float;
	var vspeed:Float;
	var friction:Float;
	var gravity:Float;
	var gravity_direction:Float;
	//
	var depth:Float;
	#if sfgml_next
	var layer:gml.layers.Layer;
	#end
	var visible:Bool;
	var persistent:Bool;
	var solid:Bool;
	//
	var sprite_index:Sprite;
	var mask_index:Sprite;
	//
	var image_index:Float;
	var image_speed:Float;
	var image_xscale:Float;
	var image_yscale:Float;
	var image_angle:Float;
	/** Internally, an UInt32 */
	var image_blend:Int;
	var image_alpha:Float;
	//
	var path_index:PointPath;
	var path_position:Float;
	var path_positionprevious:Float;
	var path_endaction:Int;
	var path_orientation:Int;
	var path_scale:Float;
	var path_speed:Float;
	//
	var timeline_index:Int;
	var timeline_loop:Int;
	var timeline_position:Float;
	var timeline_running:Bool;
	var timeline_speed:Float;
	//
	var sprite_height(default, never):Float;
	var sprite_width(default, never):Float;
	var sprite_xoffset(default, never):Float;
	var sprite_yoffset(default, never):Float;
	//
	var image_number(default, never):Int;
	var image_single:Float;
	//
	var bbox_bottom(default, never):Float;
	var bbox_left(default, never):Float;
	var bbox_right(default, never):Float;
	var bbox_top(default, never):Float;
	// Physics
	var phy_active:Bool;
	var phy_angular_damping:Float;
	var phy_angular_velocity:Float;
	var phy_bullet:Bool;
	var phy_col_normal_x:Float;
	var phy_col_normal_y:Float;
	var phy_collision_points(default, never):Int;
	var phy_collision_x(default, never):Array<Float>;
	var phy_collision_y(default, never):Array<Float>;
	var phy_com_x(default, never):Float;
	var phy_com_y(default, never):Float;
	var phy_dynamic:Bool;
	var phy_fixed_rotation:Bool;
	var phy_inertia:Float;
	var phy_kinematic:Bool;
	var phy_linear_damping:Float;
	var phy_linear_velocity_x:Float;
	var phy_linear_velocity_y:Float;
	var phy_mass:Float;
	var phy_position_x:Float;
	var phy_position_xprevious:Float;
	var phy_position_y:Float;
	var phy_position_yprevious:Float;
	var phy_rotation:Float;
	var phy_sleeping(default, never):Bool;
	var phy_speed:Float;
	var phy_speed_x:Float;
	var phy_speed_y:Float;
	//
}

abstract InstanceAlarms(Instance) {
	public inline function new(q:Instance) this = q;
	@:arrayAccess public inline function get(i:Int):Int {
		return raw("{0}.alarm[{1}]", this, i);
	}
	public inline function set(i:Int, v:Int):Void {
		raw("{0}.alarm[{1}] = {2}", this, i, v);
	}
	@:arrayAccess private inline function rset(i:Int, v:Int):Int {
		raw("{0}.alarm[{1}] = {2}", this, i, v);
		return v;
	}
}
