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
	private inline function set_viewX(x:Float):Float {
		setViewPos(x, viewY);
		return x;
	}
	
	public var viewY(get, set):Float;
	private function get_viewY():Float;
	private inline function set_viewY(y:Float):Float {
		setViewPos(viewX, y);
		return y;
	}
	
	public function setViewPos(x:Float, y:Float):Void;
	//}
	
	//{
	public var viewWidth(get, set):Float;
	private function get_viewWidth():Float;
	private inline function set_viewWidth(w:Float):Float {
		setViewSize(w, viewHeight);
		return w;
	}
	
	public var viewHeight(get, set):Float;
	private function get_viewHeight():Float;
	private inline function set_viewHeight(h:Float):Float {
		setViewSize(viewWidth, h);
		return h;
	}
	
	public function setViewSize(w:Float, h:Float):Void;
	//}
	
	//{
	public var viewSpeedX(get, set):Float;
	private function get_viewSpeedX():Float;
	private inline function set_viewSpeedX(sx:Float):Float {
		setViewSpeed(sx, viewSpeedY);
		return sx;
	}
	
	public var viewSpeedY(get, set):Float;
	private function get_viewSpeedY():Float;
	private inline function set_viewSpeedY(sy:Float):Float {
		setViewSpeed(viewSpeedX, sy);
		return sy;
	}
	
	public function setViewSpeed(sx:Float, sy:Float):Void;
	//}
	
	//{
	public var viewBorderX(get, set):Float;
	private function get_viewBorderX():Float;
	private inline function set_viewBorderX(v:Float):Float {
		setViewBorder(v, viewBorderY); return v;
	}
	
	public var viewBorderY(get, set):Float;
	private function get_viewBorderY():Float;
	private inline function set_viewBorderY(v:Float):Float {
		setViewBorder(viewBorderX, v); return v;
	}
	
	public function setViewBorder(bx:Float, by:Float):Void;
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
