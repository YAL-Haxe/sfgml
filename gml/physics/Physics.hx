package gml.physics;
import gml.assets.Object;
import gml.ds.ArrayList;
import haxe.extern.EitherType;

/**
 * ...
 * @author YellowAfterlife
 */
@:std
extern class Physics {
	@:expose("collision_point")
	static function pointCast<T:Instance>(x:Float, y:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool
	):T;
	
	@:expose("collision_point_list")
	static function pointCastList<T:Instance>(x:Float, y:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool,
		list:ArrayList<T>, ordered:Bool
	):Int;
	
	@:expose("collision_circle")
	static function circleCast<T:Instance>(x:Float, y:Float, rad:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool
	):T;
	
	@:expose("collision_circle_list")
	static function circleCastList<T:Instance>(x:Float, y:Float, rad:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool,
		list:ArrayList<T>, ordered:Bool
	):Int;
	
	@:expose("collision_line")
	static function lineCast<T:Instance>(x1:Float, y1:Float, x2:Float, y2:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool
	):T;
	
	@:expose("collision_line_list")
	static function lineCastList<T:Instance>(x1:Float, y1:Float, x2:Float, y2:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool,
		list:ArrayList<T>, ordered:Bool
	):Int;
	
	@:expose("collision_rectangle")
	static function rectCast<T:Instance>(x1:Float, y1:Float, x2:Float, y2:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool
	):T;
	
	@:expose("collision_rectangle_list")
	static function rectCastList<T:Instance>(x1:Float, y1:Float, x2:Float, y2:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool,
		list:ArrayList<T>, ordered:Bool
	):Int;
	
	@:expose("collision_ellipse")
	static function ellipseCast<T:Instance>(x1:Float, y1:Float, x2:Float, y2:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool
	):T;
	
	@:expose("collision_ellipse_list")
	static function ellipseCastList<T:Instance>(x1:Float, y1:Float, x2:Float, y2:Float,
		obj:EitherType<ObjectOf<T>, T>, prec:Bool, notme:Bool,
		list:ArrayList<T>, ordered:Bool
	):Int;
}