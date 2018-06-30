package gml.physics;
import gml.Instance;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("physics_fixture") @:snakeCase
extern class Fixture {
	public function new():Void;
	@:native("delete") public function destroy():Void;
	public function bind(target:Instance):Void;
	
	public function setAwake(awake:Bool):Void;
	public function setAngularDamping(damping:Float):Void;
	public function setCollisionGroup(group:Int):Void;
	public function setDensity(density:Float):Void;
	public function setFriction(f:Float):Void;
	public function setKinematic():Void;
	public function setLinearDamping(damping:Float):Void;
	public function setRestitution(r:Float):Void;
	public function setSensor(enable:Bool):Void;
	
	public function setPolygonShape():Void;
	public function addPoint(x:Float, y:Float):Void;
}
