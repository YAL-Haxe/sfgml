package gml.gpu;
import gml.assets.Object;
import gml.assets.Script;
import haxe.extern.EitherType;

/**
 * ...
 * @author YellowAfterlife
 */
@:std @:native("camera") @:snakeCase
extern class Camera {
	public function new():Void;
	public static function createView(
		rx:Float, ry:Float, rw:Float, rh:Float,
		?angle:Float, ?object:CameraTarget,
		?xspeed:Float, ?yspeed:Float, ?xborder:Float, ?yborder:Float
	):Camera;
	public function destroy():Void;
	
	//
	public var active(get, set):Bool;
	private function get_active():Bool;
	public function setActive(z:Bool):Void;
	private inline function set_active(z:Bool):Bool {
		setActive(z);
		return z;
	}
	
	//{
	public var beginScript(get, set):Void->Void;
	private function get_beginScript():Void->Void;
	public function setBeginScript(fn:Void->Void):Void;
	private inline function set_beginScript(fn:Void->Void):Void->Void {
		setBeginScript(fn); return fn;
	}
	
	public var endScript(get, set):Void->Void;
	private function get_endScript():Void->Void;
	public function setEndScript(fn:Void->Void):Void;
	private inline function set_endScript(fn:Void->Void):Void->Void {
		setEndScript(fn); return fn;
	}
	
	public var updateScript(get, set):Void->Void;
	private function get_updateScript():Void->Void;
	public function setUpdateScript(fn:Void->Void):Void;
	private inline function set_updateScript(fn:Void->Void):Void->Void {
		setUpdateScript(fn); return fn;
	}
	//}
	
	//{
	public var projMat(get, set):Matrix;
	private function get_projMat():Matrix;
	public function setProjMat(mtx:Matrix):Void;
	private inline function set_projMat(mtx:Matrix):Matrix {
		setProjMat(mtx);
		return mtx;
	}
	
	//
	public var viewMat(get, set):Matrix;
	private function get_viewMat():Matrix;
	public function setViewMat(mtx:Matrix):Void;
	private inline function set_viewMat(mtx:Matrix):Matrix {
		setViewMat(mtx);
		return mtx;
	}
	//}
	
	//{
	public var viewAngle(get, set):Float;
	private function get_viewAngle():Float;
	public function setViewAngle(angle:Float):Void;
	private inline function set_viewAngle(angle:Float):Float {
		setViewAngle(angle);
		return angle;
	}
	
	public var viewX(get, set):Float;
	private function get_viewX():Float;
	public function setViewX(x:Float):Void;
	private inline function set_viewX(x:Float):Float {
		setViewX(x);
		return x;
	}
	
	public var viewY(get, set):Float;
	private function get_viewY():Float;
	public function setViewY(y:Float):Void;
	private inline function set_viewY(y:Float):Float {
		setViewY(y);
		return y;
	}
	
	public var viewWidth(get, set):Float;
	private function get_viewWidth():Float;
	public function setViewWidth(w:Float):Void;
	private inline function set_viewWidth(w:Float):Float {
		setViewWidth(w);
		return w;
	}
	
	public var viewHeight(get, set):Float;
	private function get_viewHeight():Float;
	public function setViewHeight(h:Float):Void;
	private inline function set_viewHeight(h:Float):Float {
		setViewHeight(h);
		return h;
	}
	//}
	
	//{
	public var viewSpeedX(get, set):Float;
	private function get_viewSpeedX():Float;
	public function setViewSpeedX(sx:Float):Void;
	private inline function set_viewSpeedX(sx:Float):Float {
		setViewSpeedX(sx);
		return sx;
	}
	
	public var viewSpeedY(get, set):Float;
	private function get_viewSpeedY():Float;
	public function setViewSpeedY(sy:Float):Void;
	private inline function set_viewSpeedY(sy:Float):Float {
		setViewSpeedY(sy);
		return sy;
	}
	//}
	
	//{
	public var viewBorderX(get, set):Float;
	private function get_viewBorderX():Float;
	public function setViewBorderX(v:Float):Void;
	private inline function set_viewBorderX(v:Float):Float {
		setViewBorderX(v); return v;
	}
	
	public var viewBorderY(get, set):Float;
	private function get_viewBorderY():Float;
	public function setViewBorderY(v:Float):Void;
	private inline function set_viewBorderY(v:Float):Float {
		setViewBorderY(v); return v;
	}
	//}
	
	public var viewTarget(get, set):CameraTarget;
	private function get_viewTarget():CameraTarget;
	public function setViewTarget(t:CameraTarget):Void;
	private inline function set_viewTarget(t:CameraTarget):CameraTarget {
		setViewTarget(t); return t;
	}
	
	//
	public static var defCamera(get, set):Camera;
	@:native("get_default") private static function get_defCamera():Camera;
	@:native("set_default") private static function setDefCamera(c:Camera):Void;
	private static inline function set_defCamera(c:Camera):Camera {
		setDefCamera(c);
		return c;
	}
}
typedef CameraTarget = EitherType<Object, Instance>;
