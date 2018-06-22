package gml.layers;
import haxe.extern.EitherType;
import gml.assets.*;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("layer") @:snakeCase
extern class Layer {
	public static inline var defValue:Layer = cast -1;
	@:native("exists") public static function isValid(layer:EitherType<Layer, String>):Bool;
	@:native("get_id") public static function find(name:String):Layer;
	@:native("get_id_at_depth") public static function findAt(depth:Float):Array<Layer>;
	//
	public function new(depth:Float, ?name:String):Void;
	public function destroy():Void;
	//
	public var name(get, never):String;
	private function get_name():String;
	
	//
	public var depth(get, set):Float;
	private function get_depth():Float;
	@:native("depth") private function raw_depth(v:Float):Void;
	private inline function set_depth(v:Float):Float {
		raw_depth(v);
		return v;
	}
	
	//
	public var visible(get, set):Bool;
	private function get_visible():Bool;
	@:native("set_visible") private function raw_visible(v:Bool):Void;
	private inline function set_visible(v:Bool):Bool {
		raw_visible(v);
		return v;
	}
	
	//
	public var x(get, set):Float;
	private function get_x():Float;
	@:native("x") private function raw_x(v:Float):Void;
	private inline function set_x(v:Float):Float {
		raw_x(v);
		return v;
	}
	
	//
	public var y(get, set):Float;
	private function get_y():Float;
	@:native("y") private function raw_y(v:Float):Void;
	private inline function set_y(v:Float):Float {
		raw_y(v);
		return v;
	}
	
	//
	public var hspeed(get, set):Float;
	private function get_hspeed():Float;
	@:native("hspeed") private function raw_hspeed(v:Float):Void;
	private inline function set_hspeed(v:Float):Float {
		raw_hspeed(v);
		return v;
	}
	
	//
	public var vspeed(get, set):Float;
	private function get_vspeed():Float;
	@:native("vspeed") private function raw_vspeed(v:Float):Void;
	private inline function set_vspeed(v:Float):Float {
		raw_vspeed(v);
		return v;
	}
	
	//
	public var shader(get, set):Shader;
	private function get_shader():Shader;
	@:native("shader") private function raw_shader(v:Shader):Void;
	private inline function set_shader(v:Shader):Shader {
		raw_shader(v);
		return v;
	}
}
/* autogen:
function gen(name, type) { return `//
	public var ${name}(get, set):${type};
	private function get_${name}():${type};
	@:native("${name}") private function raw_${name}(a:${type}):Void;
	private inline function set_${name}(v:${type}):${type} {
		raw_${name}(v);
		return v;
	}`; }
*/
