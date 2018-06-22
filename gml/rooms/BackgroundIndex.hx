package gml.rooms;

import gml.assets.Background;
import gml.ds.Color;

/**
 * ...
 * @author YellowAfterlife
 */
abstract BackgroundIndex(Int) from Int to Int {
	
	public var index(get, set):Background;
	private inline function get_index():Background {
		return BackgroundImpl.index[this];
	}
	private inline function set_index(val:Background):Background {
		BackgroundImpl.index[this] = val;
		return val;
	}
	
	public var visible(get, set):Bool;
	private inline function get_visible():Bool {
		return BackgroundImpl.visible[this];
	}
	private inline function set_visible(val:Bool):Bool {
		BackgroundImpl.visible[this] = val;
		return val;
	}
	
	public var foreground(get, set):Bool;
	private inline function get_foreground():Bool {
		return BackgroundImpl.foreground[this];
	}
	private inline function set_foreground(val:Bool):Bool {
		BackgroundImpl.foreground[this] = val;
		return val;
	}
	
	public var htiled(get, set):Bool;
	private inline function get_htiled():Bool {
		return BackgroundImpl.htiled[this];
	}
	private inline function set_htiled(val:Bool):Bool {
		BackgroundImpl.htiled[this] = val;
		return val;
	}
	
	public var vtiled(get, set):Bool;
	private inline function get_vtiled():Bool {
		return BackgroundImpl.vtiled[this];
	}
	private inline function set_vtiled(val:Bool):Bool {
		BackgroundImpl.vtiled[this] = val;
		return val;
	}
	
	public var blend(get, set):Color;
	private inline function get_blend():Color {
		return BackgroundImpl.blend[this];
	}
	private inline function set_blend(val:Color):Color {
		BackgroundImpl.blend[this] = val;
		return val;
	}
	
	public var alpha(get, set):Float;
	private inline function get_alpha():Float {
		return BackgroundImpl.alpha[this];
	}
	private inline function set_alpha(val:Float):Float {
		BackgroundImpl.alpha[this] = val;
		return val;
	}
	
	public var x(get, set):Float;
	private inline function get_x():Float {
		return BackgroundImpl.x[this];
	}
	private inline function set_x(val:Float):Float {
		BackgroundImpl.x[this] = val;
		return val;
	}
	
	public var y(get, set):Float;
	private inline function get_y():Float {
		return BackgroundImpl.y[this];
	}
	private inline function set_y(val:Float):Float {
		BackgroundImpl.y[this] = val;
		return val;
	}
	
	public var hspeed(get, set):Float;
	private inline function get_hspeed():Float {
		return BackgroundImpl.hspeed[this];
	}
	private inline function set_hspeed(val:Float):Float {
		BackgroundImpl.hspeed[this] = val;
		return val;
	}
	
	public var vspeed(get, set):Float;
	private inline function get_vspeed():Float {
		return BackgroundImpl.vspeed[this];
	}
	private inline function set_vspeed(val:Float):Float {
		BackgroundImpl.vspeed[this] = val;
		return val;
	}
	
	public var xscale(get, set):Float;
	private inline function get_xscale():Float {
		return BackgroundImpl.xscale[this];
	}
	private inline function set_xscale(val:Float):Float {
		BackgroundImpl.xscale[this] = val;
		return val;
	}
	
	public var yscale(get, set):Float;
	private inline function get_yscale():Float {
		return BackgroundImpl.yscale[this];
	}
	private inline function set_yscale(val:Float):Float {
		BackgroundImpl.yscale[this] = val;
		return val;
	}
	
	public var width(get, set):Float;
	private inline function get_width():Float {
		return BackgroundImpl.width[this];
	}
	private inline function set_width(val:Float):Float {
		BackgroundImpl.xscale[this] = val / index.width;
		return val;
	}
	
	public var height(get, set):Float;
	private inline function get_height():Float {
		return BackgroundImpl.height[this];
	}
	private inline function set_height(val:Float):Float {
		BackgroundImpl.yscale[this] = val / index.height;
		return val;
	}
	
}
/* autogen:
function gen(name, type, impl) {
return `
public var ${name}(get, set):${type};
	private inline function get_${name}():${type} {
		return ${impl}.${name}[this];
	}
	private inline function set_${name}(val:${type}):${type} {
		${impl}.${name}[this] = val;
		return val;
	}
`;
}
*/
@:std @:native("background") @:noRefWrite
private extern class BackgroundImpl {
	static var index:Array<gml.assets.Background>;
	static var visible:Array<Bool>;
	static var blend:Array<Color>;
	static var alpha:Array<Float>;
	static var x:Array<Float>;
	static var y:Array<Float>;
	static var foreground:Array<Bool>;
	static var htiled:Array<Bool>;
	static var vtiled:Array<Bool>;
	static var hspeed:Array<Float>;
	static var vspeed:Array<Float>;
	static var width:Array<Float>;
	static var height:Array<Float>;
	static var xscale:Array<Float>;
	static var yscale:Array<Float>;
}
